#!/bin/bash
set -e

echo "=== [BUILD-STEP-1] Environment Info ==="
echo "PWD: $(pwd)"
echo "USER: $(whoami)"
echo "HOME: $HOME"
echo "GIT_DIR: $(git rev-parse --git-dir 2>/dev/null || echo 'not a git repo')"
echo "Python3: $(command -v python3 2>/dev/null || echo 'not found')"
echo "Node: $(node --version 2>/dev/null || echo 'not found')"
echo "NPM: $(npm --version 2>/dev/null || echo 'not found')"

echo "=== [BUILD-STEP-2] Git Submodule Status ==="
git submodule status 2>&1 || echo "git submodule status failed"

echo "=== [BUILD-STEP-3] Initializing git submodules ==="
echo "[3a] Initializing docs-construct-ai..."
git submodule update --init docs-construct-ai 2>&1 && echo "[3a] SUCCESS: docs-construct-ai initialized" || echo "[3a] WARNING: docs-construct-ai submodule init failed"

echo "[3b] Initializing docs-paperclip..."
git submodule update --init docs-paperclip 2>&1 && echo "[3b] SUCCESS: docs-paperclip initialized" || echo "[3b] WARNING: docs-paperclip submodule init failed"

echo "[3c] Initializing hermes_agent..."
git submodule update --init hermes_agent 2>&1 && echo "[3c] SUCCESS: hermes_agent initialized" || echo "[3c] WARNING: hermes_agent submodule init failed"

echo "=== [BUILD-STEP-4] Verifying hermes_agent directory ==="
echo "[4a] hermes_agent directory exists: $(test -d hermes_agent && echo YES || echo NO)"
echo "[4b] hermes_agent/run.sh exists: $(test -f hermes_agent/run.sh && echo YES || echo NO)"
echo "[4c] hermes_agent directory contents:"
ls -la hermes_agent/ 2>&1 || echo "Cannot list hermes_agent directory"
echo "[4d] hermes_agent/.git exists: $(test -d hermes_agent/.git && echo YES || echo NO)"

# Fallback: if hermes_agent is still empty, clone it directly
if [ ! -f hermes_agent/run.sh ]; then
    echo "=== [BUILD-STEP-5] FALLBACK: hermes_agent/run.sh not found, cloning directly ==="
    rm -rf hermes_agent
    echo "[5a] Cloning https://github.com/tennantalistair/hermes-agent.git..."
    git clone https://github.com/tennantalistair/hermes-agent.git hermes_agent 2>&1
    echo "[5b] Clone result: $?"
    echo "[5c] hermes_agent/run.sh exists after clone: $(test -f hermes_agent/run.sh && echo YES || echo NO)"
    echo "[5d] hermes_agent directory contents after clone:"
    ls -la hermes_agent/ 2>&1
else
    echo "=== [BUILD-STEP-5] SKIPPED: hermes_agent/run.sh already exists ==="
fi

echo "=== [BUILD-STEP-6] Final hermes_agent verification ==="
echo "[6a] run.sh exists: $(test -f hermes_agent/run.sh && echo YES || echo NO)"
echo "[6b] run.sh is executable: $(test -x hermes_agent/run.sh && echo YES || echo NO)"
echo "[6c] run.sh first 5 lines:"
head -5 hermes_agent/run.sh 2>&1 || echo "Cannot read run.sh"
echo "[6d] hermes_agent file count: $(find hermes_agent -type f 2>/dev/null | wc -l)"

echo "=== [BUILD-STEP-7] Installing pnpm ==="
npm install -g pnpm@9.15.4

echo "=== [BUILD-STEP-8] Installing dependencies ==="
# Must include devDependencies because shared package's tsconfig includes test files
# that import vitest, and build runs tsc which checks those imports
pnpm install --frozen-lockfile --prod=false

echo "=== [BUILD-STEP-9] Building packages ==="
# shared first - it has no internal workspace deps
pnpm --filter @paperclipai/shared build
# Then db - it imports from @paperclipai/shared
pnpm --filter @paperclipai/db build
pnpm --filter @paperclipai/adapter-utils build
pnpm --filter @paperclipai/adapter-claude-local build
pnpm --filter @paperclipai/adapter-codex-local build
pnpm --filter @paperclipai/adapter-cursor-local build
pnpm --filter @paperclipai/adapter-gemini-local build
pnpm --filter @paperclipai/adapter-openclaw-gateway build
pnpm --filter @paperclipai/adapter-opencode-local build
pnpm --filter @paperclipai/adapter-pi-local build
pnpm --filter @paperclipai/plugin-sdk build
pnpm --filter @paperclipai/ui build
# Skip preflight:workspace-links for server build - workspace links are already correct after pnpm install
cd server && tsc && mkdir -p dist/onboarding-assets && cp -R src/onboarding-assets/. dist/onboarding-assets/ && cd ..

echo "=== [BUILD-STEP-10] Setting up Python and Hermes Agent ==="
# Install Python and pip if not available
if ! command -v python3 &> /dev/null; then
    echo "[10a] Installing Python3..."
    apt-get update && apt-get install -y python3 python3-pip python3-venv
else
    echo "[10a] Python3 already available: $(python3 --version)"
fi

# Set up Hermes agent virtual environment
echo "[10b] Setting up Hermes agent virtual environment..."
cd hermes_agent
echo "[10c] Current directory: $(pwd)"
echo "[10d] Directory contents:"
ls -la 2>&1

python3 -m venv venv 2>&1
echo "[10e] venv creation result: $?"

source venv/bin/activate
echo "[10f] venv activated: $(which python)"

# Install Hermes agent dependencies
echo "[10g] Installing Hermes agent dependencies..."
pip install --upgrade pip 2>&1 | tail -3
echo "[10h] pip upgrade result: $?"

pip install -e . 2>&1 | tail -10
echo "[10i] pip install result: $?"

# Verify hermes command is available
echo "[10j] Verifying Hermes installation..."
./hermes --version 2>&1 || echo "[10j] Hermes command not found, but continuing build"

# Return to project root
cd ..
deactivate

echo "=== [BUILD-STEP-11] Final deployment verification ==="
echo "[11a] server/dist/index.js: $(test -f server/dist/index.js && echo EXISTS || echo MISSING)"
echo "[11b] hermes_agent/run.sh: $(test -f hermes_agent/run.sh && echo EXISTS || echo MISSING)"
echo "[11c] hermes_agent/venv: $(test -d hermes_agent/venv && echo EXISTS || echo MISSING)"
echo "[11d] Full hermes_agent tree (top 2 levels):"
find hermes_agent -maxdepth 2 -type f 2>&1 | head -30

echo "=== [BUILD-COMPLETE] Build finished ==="