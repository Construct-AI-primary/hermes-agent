#!/bin/bash
# Docker/Podman entrypoint: bootstrap config files into the mounted volume, then run hermes.
set -e

HERMES_HOME="${HERMES_HOME:-/opt/data}"
INSTALL_DIR="/opt/hermes"

# --- Privilege dropping via gosu ---
# When started as root (the default for Docker, or fakeroot in rootless Podman),
# optionally remap the hermes user/group to match host-side ownership, fix volume
# permissions, then re-exec as hermes.
if [ "$(id -u)" = "0" ]; then
    if [ -n "$HERMES_UID" ] && [ "$HERMES_UID" != "$(id -u hermes)" ]; then
        echo "Changing hermes UID to $HERMES_UID"
        usermod -u "$HERMES_UID" hermes
    fi

    if [ -n "$HERMES_GID" ] && [ "$HERMES_GID" != "$(id -g hermes)" ]; then
        echo "Changing hermes GID to $HERMES_GID"
        # -o allows non-unique GID (e.g. macOS GID 20 "staff" may already exist
        # as "dialout" in the Debian-based container image)
        groupmod -o -g "$HERMES_GID" hermes 2>/dev/null || true
    fi

    actual_hermes_uid=$(id -u hermes)
    if [ "$(stat -c %u "$HERMES_HOME" 2>/dev/null)" != "$actual_hermes_uid" ]; then
        echo "$HERMES_HOME is not owned by $actual_hermes_uid, fixing"
        # In rootless Podman the container's "root" is mapped to an unprivileged
        # host UID — chown will fail.  That's fine: the volume is already owned
        # by the mapped user on the host side.
        chown -R hermes:hermes "$HERMES_HOME" 2>/dev/null || \
            echo "Warning: chown failed (rootless container?) — continuing anyway"
    fi

    echo "Dropping root privileges"
    exec gosu hermes "$0" "$@"
fi

# --- Running as hermes from here ---
source "${INSTALL_DIR}/.venv/bin/activate"

# Create essential directory structure.  Cache and platform directories
# (cache/images, cache/audio, platforms/whatsapp, etc.) are created on
# demand by the application — don't pre-create them here so new installs
# get the consolidated layout from get_hermes_dir().
# The "home/" subdirectory is a per-profile HOME for subprocesses (git,
# ssh, gh, npm …).  Without it those tools write to /root which is
# ephemeral and shared across profiles.  See issue #4426.
mkdir -p "$HERMES_HOME"/{cron,sessions,logs,hooks,memories,skills,skins,plans,workspace,home}

# .env
if [ ! -f "$HERMES_HOME/.env" ]; then
    cp "$INSTALL_DIR/.env.example" "$HERMES_HOME/.env"
fi

# config.yaml
if [ ! -f "$HERMES_HOME/config.yaml" ]; then
    cp "$INSTALL_DIR/cli-config.yaml.example" "$HERMES_HOME/config.yaml"
fi

# SOUL.md
if [ ! -f "$HERMES_HOME/SOUL.md" ]; then
    cp "$INSTALL_DIR/docker/SOUL.md" "$HERMES_HOME/SOUL.md"
fi

# Sync bundled skills (manifest-based so user edits are preserved)
if [ -d "$INSTALL_DIR/skills" ]; then
    python3 "$INSTALL_DIR/tools/skills_sync.py"
fi

# Mode-driven execution: HERMES_MODE overrides default interactive CLI.
# Used by Render (dockerCommand) and other container deployments.
case "${HERMES_MODE:-chat}" in
    serve|server|api)
        # Render sets $PORT; local/Docker fallbacks: API_SERVER_PORT, then 8642
        _port="${PORT:-${API_SERVER_PORT:-8642}}"
        echo "[entrypoint] Resolved port: $_port (RENDER_PORT=${RENDER_PORT:-unset}, PORT=${PORT:-unset}, API_SERVER_PORT=${API_SERVER_PORT:-unset})"
        exec hermes serve --host "${HOST:-0.0.0.0}" --port "${_port}"
        ;;
    worker)
        # Paperclip unified worker: poll Supabase for queued runs, execute with Hermes
        echo "[entrypoint] Starting Paperclip worker mode (polls Supabase)"
        exec python3 "$INSTALL_DIR/supabase_paperclip_worker.py"
        ;;
    both)
        # Run both API server and worker concurrently with visible logging
        echo "[entrypoint] Starting both API server and Paperclip worker"

        # Start API server in background with explicit logging prefix
        _port="${PORT:-${API_SERVER_PORT:-8642}}"
        echo "[entrypoint] Starting API server on port $_port"
        
        # Start API server and capture both stdout and stderr
        hermes serve --host "${HOST:-0.0.0.0}" --port "${_port}" 2>&1 | sed 's/^/[API] /' &
        API_SERVER_PID=$!

        # Wait for API server to start (check if it's listening)
        echo "[entrypoint] Waiting for API server to be ready..."
        for i in {1..30}; do
            if curl -s "http://localhost:$_port/health" > /dev/null 2>&1; then
                echo "[entrypoint] API server is ready"
                break
            fi
            # Check if process died
            if ! kill -0 $API_SERVER_PID 2>/dev/null; then
                echo "[entrypoint] ERROR: API server process died immediately"
                exit 1
            fi
            sleep 1
            if [ $i -eq 30 ]; then
                echo "[entrypoint] ERROR: API server failed to start after 30 seconds"
                kill $API_SERVER_PID 2>/dev/null || true
                exit 1
            fi
        done

        # Start worker in background with explicit logging prefix
        echo "[entrypoint] Starting Paperclip worker"
        python3 "$INSTALL_DIR/supabase_paperclip_worker.py" > >(sed 's/^/[WORKER] /') 2> >(sed 's/^/[WORKER] /' >&2) &
        WORKER_PID=$!

        # Wait for either process to exit
        wait -n
        EXIT_CODE=$?

        # Kill the other process
        if kill -0 $API_SERVER_PID 2>/dev/null; then
            echo "[entrypoint] Stopping API server"
            kill $API_SERVER_PID
        fi
        if kill -0 $WORKER_PID 2>/dev/null; then
            echo "[entrypoint] Stopping worker"
            kill $WORKER_PID
        fi

        exit $EXIT_CODE
        ;;
    *)
        exec hermes "$@"
        ;;
esac
