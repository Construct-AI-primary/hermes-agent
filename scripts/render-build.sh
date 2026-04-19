#!/bin/bash
set -e

echo "=== Initializing git submodules ==="
git submodule update --init --recursive

echo "=== Installing pnpm ==="
npm install -g pnpm@9.15.4

echo "=== Installing dependencies ==="
# Must include devDependencies because shared package's tsconfig includes test files
# that import vitest, and build runs tsc which checks those imports
pnpm install --frozen-lockfile --prod=false

echo "=== Building packages ==="
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

echo "=== Setting up Python and Hermes Agent ==="
# Install Python and pip if not available
if ! command -v python3 &> /dev/null; then
    echo "Installing Python3..."
    apt-get update && apt-get install -y python3 python3-pip python3-venv
fi

# Set up Hermes agent virtual environment
echo "Setting up Hermes agent virtual environment..."
cd hermes_agent
python3 -m venv venv
source venv/bin/activate

# Install Hermes agent dependencies
echo "Installing Hermes agent dependencies..."
pip install --upgrade pip
pip install -e .

# Verify hermes command is available
echo "Verifying Hermes installation..."
./hermes --version || echo "Hermes command not found, but continuing build"

# Return to project root
cd ..
deactivate

echo "=== Build complete ==="
ls -la server/dist/index.js 2>/dev/null || echo "WARNING: server/dist/index.js not found!"
