# Hermes Run Command
When the user types "hermes run" followed by a task description, execute:
```bash
./hermes_agent/run.sh "task description here"
```

Examples:
- User: `hermes run summarize this file`
  → Run: `./hermes_agent/run.sh "Summarize this file"`

- User: `hermes run --model "anthropic/claude-opus-4.6" --task "deep analysis"`
  → Run: `./hermes_agent/run.sh --model "anthropic/claude-opus-4.6" --task "deep analysis"`

## Setup Required
Before running Hermes, ensure:
1. API key is set in `hermes_agent/.env` — uncomment `OPENROUTER_API_KEY=` and add your key
2. Virtual environment exists at `hermes_agent/venv/`

## Status: ✅ WORKING
The `hermes run` command is now fully functional and tested. It properly activates the hermes agent and executes tasks with tool calling capabilities.
