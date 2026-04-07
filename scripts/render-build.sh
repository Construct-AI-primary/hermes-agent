#!/bin/bash
set -e

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

echo "=== Build complete ==="
ls -la server/dist/index.js 2>/dev/null || echo "WARNING: server/dist/index.js not found!"