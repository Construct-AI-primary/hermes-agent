"""
Paperclip Unified Worker — polls heartbeat_runs for Hermes-type agents,
executes issues by cloning repos and running Hermes, then posts results.
"""
import json
import logging
import os
import subprocess
import sys
import tempfile
import time
import uuid
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from typing import Any, Dict, List, Optional

logger = logging.getLogger("paperclip_worker")


# =============================================================================
# Config
# =============================================================================

class WorkerConfig:
    supabase_url: str = os.getenv("SUPABASE_URL", "")
    supabase_service_role_key: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
    github_token: str = os.getenv("GITHUB_TOKEN", "")
    poll_interval_seconds: float = float(os.getenv("POLL_INTERVAL_SECONDS", "5"))
    max_runs_per_process: Optional[int] = (
        int(os.getenv("PAPERCLIP_MAX_RUNS_PER_PROCESS", "0")) or None
    )
    _clone_cache: Dict[str, Path] = {}

    def __post_init__(self):
        missing = [k for k in ("supabase_url", "supabase_service_role_key") if not getattr(self, k)]
        if missing:
            raise ValueError(f"Missing env vars: {missing}")


def _load_config_from_env() -> WorkerConfig:
    return WorkerConfig()


# =============================================================================
# Supabase client
# =============================================================================

def _create_supabase_client(cfg: WorkerConfig):
    from supabase import create_client
    return create_client(cfg.supabase_url, cfg.supabase_service_role_key)


def _safe_json(obj: Any) -> Any:
    try:
        json.dumps(obj)
        return obj
    except Exception:
        return {"_unserializable": str(type(obj))}


def _get_data(res) -> List[Dict[str, Any]]:
    """Extract rows from supabase-py response (handles both object and dict forms)."""
    if hasattr(res, "data") and res.data is not None:
        return res.data
    if isinstance(res, dict):
        return res.get("data") or []
    return []


# =============================================================================
# Paperclip data access — unified multi-agent
# =============================================================================

def _fetch_agent_models(supabase, agent_ids: List[str]) -> Dict[str, Dict[str, Any]]:
    """Fetch agent_models rows for given agent IDs. Returns dict keyed by agent_id."""
    if not agent_ids:
        return {}
    res = (
        supabase.table("agent_models")
        .select("agent_id, model_id, temperature, max_tokens")
        .in_("agent_id", agent_ids)
        .eq("is_active", True)
        .eq("assignment_type", "primary")
        .execute()
    )
    rows = _get_data(res)
    return {r["agent_id"]: r for r in rows}


def _select_next_runs(supabase) -> List[Dict[str, Any]]:
    """
    Fetch ALL queued runs for Hermes-type agents.
    Filters to adapter_type IN ('hermes', 'hermes_local').
    Returns runs across all companies and all agent roles.
    """
    # First, get all Hermes agent IDs
    agent_res = (
        supabase.table("agents")
        .select("id, adapter_type, company_id, role, name, runtime_config, capabilities")
        .in_("adapter_type", ["hermes", "hermes_local", "http"])
        .execute()
    )
    agents_rows = _get_data(agent_res)
    if not agents_rows:
        return []

    hermes_agent_ids = [a["id"] for a in agents_rows]
    agent_map = {a["id"]: a for a in agents_rows}

    # Fetch agent_models for model/temperature/max_tokens config
    agent_models_map = _fetch_agent_models(supabase, hermes_agent_ids)

    # Fetch queued runs for these agents
    res = (
        supabase.table("heartbeat_runs")
        .select("*")
        .in_("agent_id", hermes_agent_ids)
        .eq("status", "queued")
        .order("created_at", desc=False)
        .limit(10)  # batch up to 10 at a time
        .execute()
    )
    runs = _get_data(res)

    # Attach agent info + agent_models config to each run
    for run in runs:
        agent = agent_map.get(run.get("agent_id"), {})
        run["_agent"] = agent

        # Merge agent_models (model_id → model, preserve runtime_config as fallback)
        model_row = agent_models_map.get(agent.get("id"), {})
        runtime_cfg = dict(agent.get("runtime_config") or {})
        if model_row.get("model_id"):
            runtime_cfg["model"] = model_row["model_id"]
        if model_row.get("temperature") is not None:
            runtime_cfg["temperature"] = float(model_row["temperature"])
        if model_row.get("max_tokens") is not None:
            runtime_cfg["max_tokens"] = int(model_row["max_tokens"])
        run["_runtime_config"] = runtime_cfg

    return runs


def _claim_run(supabase, run_id: str) -> bool:
    """Atomic claim: update queued → running."""
    res = (
        supabase.table("heartbeat_runs")
        .update({"status": "running", "started_at": "now()"})
        .eq("id", run_id)
        .eq("status", "queued")
        .execute()
    )
    rows = _get_data(res)
    return bool(rows)


def _release_run_to_queued(supabase, run_id: str) -> bool:
    """Release a run back to queued status (for orphaned runs without issues)."""
    res = (
        supabase.table("heartbeat_runs")
        .update({"status": "queued", "started_at": None})
        .eq("id", run_id)
        .eq("status", "running")
        .execute()
    )
    rows = _get_data(res)
    return bool(rows)


def _fetch_issue_context(supabase, run: Dict[str, Any]) -> Dict[str, Any]:
    """
    Walk the Paperclip join chain for this specific run.
    Returns flat context dict for execution.
    """
    run_id = run["id"]
    agent = run.get("_agent", {})

    # Find the issue via execution_run_id
    res = (
        supabase.table("issues")
        .select(
            "id, title, description, project_workspace_id, "
            "company_id, project_id, assignee_agent_id"
        )
        .eq("execution_run_id", run_id)
        .limit(1)
        .execute()
    )
    issue_rows = _get_data(res)
    if not issue_rows:
        return {"_error": "No issue found for this run", "_orphaned": True}
    issue = issue_rows[0]

    workspace_id = issue.get("project_workspace_id")
    repo_url = None
    cwd = None
    repo_ref = "main"

    if workspace_id:
        ws_res = (
            supabase.table("project_workspaces")
            .select("repo_url, cwd, repo_ref, default_ref")
            .eq("id", workspace_id)
            .limit(1)
            .execute()
        )
        ws_rows = _get_data(ws_res)
        if ws_rows:
            ws = ws_rows[0]
            repo_url = ws.get("repo_url")
            cwd = ws.get("cwd") or ""
            repo_ref = ws.get("repo_ref") or ws.get("default_ref") or "main"

    # Fetch company info
    company_id = issue.get("company_id")
    company_name = None
    if company_id:
        comp_res = (
            supabase.table("companies")
            .select("name")
            .eq("id", company_id)
            .limit(1)
            .execute()
        )
        comp_rows = _get_data(comp_res)
        if comp_rows:
            company_name = comp_rows[0].get("name")

    # Prefer merged agent_models config, fall back to runtime_config
    runtime_config = run.get("_runtime_config") or agent.get("runtime_config") or {}

    return {
        "issue_id": issue["id"],
        "issue_title": issue.get("title", ""),
        "issue_description": issue.get("description", ""),
        "company_id": company_id,
        "company_name": company_name,
        "project_id": issue.get("project_id"),
        "repo_url": repo_url,
        "repo_ref": repo_ref,
        "cwd": cwd,
        "agent_id": run.get("agent_id"),
        "agent_role": agent.get("role"),
        "agent_name": agent.get("name"),
        "agent_capabilities": agent.get("capabilities"),
        "adapter_type": agent.get("adapter_type", "http"),  # NEW: include adapter_type
        "agent_runtime_config": runtime_config,
        "heartbeat_run_id": run_id,
        "run_context": run.get("context_snapshot") or {},
        "_orphaned": False,
    }


def _fetch_agent_api_key(supabase, agent_id: str, company_id: str) -> Optional[str]:
    """Look up per-agent per-company API key for LLM billing."""
    res = (
        supabase.table("agent_api_keys")
        .select("token")
        .eq("agent_id", agent_id)
        .eq("company_id", company_id)
        .limit(1)
        .execute()
    )
    rows = _get_data(res)
    if rows:
        return rows[0].get("token")
    # Fallback: any key for this agent
    res = (
        supabase.table("agent_api_keys")
        .select("token")
        .eq("agent_id", agent_id)
        .limit(1)
        .execute()
    )
    rows = _get_data(res)
    return rows[0].get("token") if rows else None


# =============================================================================
# Git helpers
# =============================================================================

def _auth_git_url(repo_url: str, token: str) -> str:
    if not token:
        return repo_url
    if repo_url.startswith("https://github.com/"):
        return repo_url.replace("https://", f"https://{token}@")
    return repo_url


def _clone_repo(repo_url: str, ref: str, github_token: str, cache: Dict[str, Path]) -> Path:
    """Clone or reuse from cache."""
    cache_key = f"{repo_url}@{ref}"
    if cache_key in cache:
        logger.info("Reusing cached clone of %s @ %s", repo_url, ref)
        return cache[cache_key]

    authed_url = _auth_git_url(repo_url, github_token)
    tmp = Path(tempfile.mkdtemp(prefix="hermes_"))
    clone_dest = tmp / "repo"

    logger.info("Cloning %s (ref=%s) → %s", repo_url, ref, clone_dest)
    _run(["git", "clone", "--quiet", "--depth=1", authed_url, str(clone_dest)])
    _run(["git", "-C", str(clone_dest), "fetch", "--quiet", "origin", ref])
    _run(["git", "-C", str(clone_dest), "checkout", "--quiet", ref])

    cache[cache_key] = clone_dest
    return clone_dest


def _run(cmd: List[str], cwd: Optional[str] = None, timeout: int = 120) -> str:
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=cwd,
            timeout=timeout,
            env={**os.environ, "GIT_TERMINAL_PROMPT": "0"},
        )
        if result.returncode != 0:
            logger.warning("Command %s exited %d: %s", cmd, result.returncode, result.stderr.strip())
        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        logger.error("Command timed out after %ds: %s", timeout, cmd)
        raise


def _create_pr(repo_url: str, branch: str, title: str, body: str, github_token: str) -> str:
    """Create a GitHub PR via API. Returns PR URL."""
    parts = repo_url.rstrip("/").split("/")
    owner_repo = "/".join(parts[-2:]).replace(".git", "")

    import urllib.request

    url = f"https://api.github.com/repos/{owner_repo}/pulls"
    payload = json.dumps({
        "title": title,
        "head": branch,
        "base": "main",
        "body": body,
    }).encode("utf-8")

    req = urllib.request.Request(
        url, data=payload,
        headers={
            "Authorization": f"Bearer {github_token}",
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read())
    return data.get("html_url") or data.get("url", "")


# =============================================================================
# Hermes execution (local CLI)
# =============================================================================

def _run_hermes_agent(
    repo_path: Path,
    cwd: str,
    prompt: str,
    runtime_config: Dict[str, Any],
    github_token: str,
    api_key: Optional[str],
) -> Dict[str, Any]:
    """Run Hermes CLI in repo_path with the given prompt."""
    work_dir = repo_path / cwd if cwd else repo_path

    model = runtime_config.get("model")
    max_turns = runtime_config.get("max_turns", 20)
    temperature = runtime_config.get("temperature")

    cmd = [
        sys.executable, "-m", "hermes",
        "--model", model or "openrouter/qwen/qwen-3-6-plus",
        "--max-iterations", str(max_turns),
        "--no-stream",
        "--message", prompt,
    ]
    if temperature is not None:
        cmd += ["--temperature", str(temperature)]

    env = {**os.environ}
    if api_key:
        env["OPENROUTER_API_KEY"] = api_key
    if github_token:
        env["GITHUB_TOKEN"] = github_token

    # max_tokens from agent_models → HERMES_MAX_TOKENS env var for LLM API
    max_tokens = runtime_config.get("max_tokens")
    if max_tokens:
        env["HERMES_MAX_TOKENS"] = str(max_tokens)

    logger.info(
        "Running Hermes (model=%s, turns=%d, agent_role=%s) in %s",
        model or "default", max_turns,
        runtime_config.get("role", "unknown"),
        work_dir,
    )

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=str(work_dir),
            timeout=900,  # 15 min max per run
            env=env,
        )
        return {
            "exit_code": result.returncode,
            "stdout": result.stdout or "",
            "stderr": (result.stderr or "")[-500:],
        }
    except subprocess.TimeoutExpired:
        return {
            "exit_code": -1,
            "stdout": "",
            "stderr": "Hermes timed out after 900 seconds",
        }


# =============================================================================
# HTTP Adapter execution
# =============================================================================

def _run_http_adapter(
    ctx: Dict[str, Any],
    runtime_config: Dict[str, Any],
    api_key: Optional[str],
) -> Dict[str, Any]:
    """
    Execute via HTTP adapter endpoint.
    The endpoint URL should be in runtime_config or agent config.
    """
    import urllib.request
    import urllib.error

    # Get the HTTP adapter endpoint from runtime_config or use default
    endpoint = runtime_config.get("adapter_endpoint")
    if not endpoint:
        # Default to Hermes adapter on same host or configured URL
        endpoint = os.getenv("HERMES_ADAPTER_ENDPOINT", "http://localhost:8000/invoke")

    model = runtime_config.get("model", "openrouter/qwen/qwen-3-6-plus")
    max_turns = runtime_config.get("max_turns", 20)
    temperature = runtime_config.get("temperature")

    # Build the payload
    payload = {
        "prompt": ctx.get("issue_description") or ctx.get("issue_title", ""),
        "repo_url": ctx.get("repo_url"),
        "repo_ref": ctx.get("repo_ref", "main"),
        "cwd": ctx.get("cwd", ""),
        "model": model,
        "max_turns": max_turns,
        "temperature": temperature,
        "max_tokens": runtime_config.get("max_tokens"),
        "agent_id": ctx.get("agent_id"),
        "company_id": ctx.get("company_id"),
        "issue_id": ctx.get("issue_id"),
        "run_id": ctx.get("heartbeat_run_id"),
    }

    # Remove None values
    payload = {k: v for k, v in payload.items() if v is not None}

    logger.info("Calling HTTP adapter at %s with payload: %s", endpoint, json.dumps(payload, default=str)[:200])

    try:
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            endpoint,
            data=data,
            headers={
                "Content-Type": "application/json",
                "Accept": "application/json",
            },
            method="POST",
        )

        # Add API key header if available
        if api_key:
            req.add_header("Authorization", f"Bearer {api_key}")

        with urllib.request.urlopen(req, timeout=900) as resp:
            result_data = json.loads(resp.read())
            return {
                "exit_code": 0,
                "stdout": json.dumps(result_data),
                "stderr": "",
            }

    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace") if e.fp else ""
        logger.error("HTTP adapter error %d: %s", e.code, error_body[:500])
        return {
            "exit_code": e.code,
            "stdout": "",
            "stderr": f"HTTP {e.code}: {error_body[:500]}",
        }
    except Exception as exc:
        logger.error("HTTP adapter failed: %s", exc)
        return {
            "exit_code": -1,
            "stdout": "",
            "stderr": str(exc),
        }


# =============================================================================
# Execute a single run
# =============================================================================

def _execute_run(
    ctx: Dict[str, Any], cfg: WorkerConfig, supabase
) -> Dict[str, Any]:
    """Execute one Paperclip issue with the resolved agent + company config."""
    repo_url = ctx.get("repo_url")
    if not repo_url:
        return {"error": "No repo_url found in issue context"}

    repo_ref = ctx.get("repo_ref", "main")
    cwd = ctx.get("cwd", "")
    issue_title = ctx.get("issue_title", "Hermes task")
    issue_description = ctx.get("issue_description", "")
    company_id = ctx.get("company_id")
    agent_id = ctx.get("agent_id")
    runtime_config = ctx.get("agent_runtime_config", {})
    company_name = ctx.get("company_name") or "unknown"
    adapter_type = ctx.get("adapter_type", "http")  # NEW: get adapter type

    prompt = issue_description.strip() if issue_description.strip() else issue_title

    # Per-company, per-agent API key
    api_key = None
    if agent_id and company_id:
        try:
            api_key = _fetch_agent_api_key(supabase, agent_id, company_id)
        except Exception as exc:
            logger.warning("Could not fetch agent API key: %s", exc)

    # NEW: Check adapter type and execute accordingly
    if adapter_type == "http":
        # Use HTTP adapter
        result = _run_http_adapter(ctx, runtime_config, api_key)
    else:
        # Use local Hermes CLI (hermes/hermes_local)
        # Clone repo
        try:
            repo_path = _clone_repo(repo_url, repo_ref, cfg.github_token, cfg._clone_cache)
        except Exception as exc:
            return {"error": f"Clone failed: {exc}"}

        result = _run_hermes_agent(
            repo_path, cwd, prompt, runtime_config, cfg.github_token, api_key
        )

    pr_url = None
    branch_name = f"hermes-{uuid.uuid4().hex[:8]}"

    if result.get("exit_code") == 0:
        try:
            body = (
                f"**Hermes Task Result**\n"
                f"Company: {company_name}\n"
                f"Agent Role: {ctx.get('agent_role', 'unknown')}\n\n"
                f"```\n{result.get('stdout', '')}\n```"
            )
            pr_url = _create_pr(
                repo_url, branch_name,
                f"Hermes [{company_name}]: {issue_title[:50]}",
                body[:65536],
                cfg.github_token,
            )
        except Exception as exc:
            logger.warning("PR creation failed: %s", exc)

    return {
        "repo_url": repo_url,
        "repo_ref": repo_ref,
        "pr_url": pr_url,
        "exit_code": result.get("exit_code"),
        "stdout": result.get("stdout", ""),
        "stderr": result.get("stderr", ""),
    }


# =============================================================================
# Status updates
# =============================================================================

def _update_run_status(supabase, run_id: str, status: str, result: Dict[str, Any]):
    """Update heartbeat_runs with final status + result snapshot."""
    payload = {
        "status": status,
        "finished_at": "now()",
        "result_json": _safe_json({
            "exit_code": result.get("exit_code"),
            "pr_url": result.get("pr_url"),
            "stdout_excerpt": (result.get("stdout") or "")[:1000],
            "stderr_excerpt": (result.get("stderr") or "")[:500],
        }),
    }
    if status == "completed":
        payload["exit_code"] = 0
    else:
        payload["exit_code"] = result.get("exit_code", 1)
        payload["error"] = result.get("error", "unknown error")
    
    try:
        supabase.table("heartbeat_runs").update(payload).eq("id", run_id).execute()
    except Exception as exc:
        logger.warning("Could not update run status: %s", exc)


def _post_issue_comment(supabase, issue_id: str, body: str):
    try:
        supabase.table("issue_comments").insert({
            "issue_id": issue_id,
            "body": body,
        }).execute()
    except Exception as exc:
        logger.debug("Could not post issue comment: %s", exc)


# =============================================================================
# Health check server
# =============================================================================

def _start_health_server():
    port = int(os.getenv("PORT", "8080"))

    class HealthHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"OK")

        def log_message(self, format, *args):
            pass  # suppress logging

    server = HTTPServer(("0.0.0.0", port), HealthHandler)
    logger.info("Health server listening on port %s", port)
    import threading
    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()


# =============================================================================
# Main worker loop
# =============================================================================

def run_forever():
    logging.basicConfig(
        level=logging.getLevelName(os.getenv("LOG_LEVEL", "INFO")),
        format="%(asctime)s %(levelname)s %(name)s: %(message)s",
    )

    cfg = _load_config_from_env()
    supabase = _create_supabase_client(cfg)

    processed = 0
    skipped = 0
    logger.info("Paperclip unified worker starting — polling every %.1fs", cfg.poll_interval_seconds)
    logger.info("HTTP adapter endpoint: %s", os.getenv("HERMES_ADAPTER_ENDPOINT", "http://localhost:8000/invoke"))

    while True:
        if cfg.max_runs_per_process and processed >= cfg.max_runs_per_process:
            logger.info("Reached PAPERCLIP_MAX_RUNS_PER_PROCESS=%s, exiting", cfg.max_runs_per_process)
            return

        try:
            runs = _select_next_runs(supabase)
            if not runs:
                time.sleep(cfg.poll_interval_seconds)
                continue

            for run in runs:
                run_id = run["id"]
                agent_name = run.get("_agent", {}).get("name", "?")
                company = run.get("_agent", {}).get("company_id", "")[:8]

                claimed = _claim_run(supabase, run_id)
                if not claimed:
                    logger.debug("Run %s already claimed by another worker", run_id[:8])
                    continue

                logger.info(
                    "Claimed run %s — agent=%s company=%s",
                    run_id[:8], agent_name, company,
                )

                ctx = _fetch_issue_context(supabase, run)

                # NEW: Handle orphaned runs (no issue) gracefully
                if ctx.get("_orphaned"):
                    logger.info("Run %s has no associated issue (orphaned run) — releasing back to queued", run_id[:8])
                    _release_run_to_queued(supabase, run_id)
                    skipped += 1
                    continue

                if ctx.get("_error"):
                    logger.warning("Skipping run %s: %s", run_id[:8], ctx["_error"])
                    _update_run_status(supabase, run_id, "failed", {"error": ctx["_error"]})
                    continue

                result = _execute_run(ctx, cfg, supabase)

                status = "completed" if result.get("exit_code") == 0 else "failed"
                _update_run_status(supabase, run_id, status, result)

                issue_id = ctx.get("issue_id")
                if issue_id:
                    pr = result.get("pr_url")
                    if status == "completed" and pr:
                        msg = f"✅ Hermes completed task — [View PR]({pr})"
                    elif status == "completed":
                        msg = "✅ Hermes completed task"
                    else:
                        msg = f"⚠️ Hermes task failed: {result.get('error', 'unknown error')}"
                    _post_issue_comment(supabase, issue_id, msg)

                processed += 1

            # Log stats periodically
            if skipped > 0 and skipped % 10 == 0:
                logger.info("Stats: processed=%d, skipped_orphaned=%d", processed, skipped)

        except Exception:
            logger.exception("Worker loop error — retrying")
            time.sleep(max(1.0, cfg.poll_interval_seconds))


# =============================================================================
# Entry point
# =============================================================================

if __name__ == "__main__":
    PROJECT_ROOT = Path(__file__).parent.resolve()
    if str(PROJECT_ROOT) not in sys.path:
        sys.path.insert(0, str(PROJECT_ROOT))

    dotenv_path = PROJECT_ROOT / ".env"
    if dotenv_path.exists():
        try:
            from dotenv import load_dotenv
            load_dotenv(dotenv_path, override=True)
        except ImportError:
            pass

    _start_health_server()
    run_forever()
