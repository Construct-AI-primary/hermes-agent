import path from "path";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      lexical: path.resolve(__dirname, "./node_modules/lexical/Lexical.mjs"),
      // Direct alias for workspace packages - point to dist for packages with .js imports
      "@paperclipai/adapter-utils": path.resolve(__dirname, "../packages/adapter-utils/dist/index.js"),
      "@paperclipai/shared": path.resolve(__dirname, "../packages/shared/dist/index.js"),
      // Subpath exports must come BEFORE base package aliases to prevent path concatenation
      // All adapters point to dist/ since they're built before UI and use .js imports internally
      "@paperclipai/adapter-claude-local/ui": path.resolve(__dirname, "../packages/adapters/claude-local/dist/ui/index.js"),
      "@paperclipai/adapter-claude-local$": path.resolve(__dirname, "../packages/adapters/claude-local/dist/index.js"),
      "@paperclipai/adapter-codex-local/ui": path.resolve(__dirname, "../packages/adapters/codex-local/dist/ui/index.js"),
      "@paperclipai/adapter-codex-local$": path.resolve(__dirname, "../packages/adapters/codex-local/dist/index.js"),
      "@paperclipai/adapter-cursor-local/ui": path.resolve(__dirname, "../packages/adapters/cursor-local/dist/ui/index.js"),
      "@paperclipai/adapter-cursor-local$": path.resolve(__dirname, "../packages/adapters/cursor-local/dist/index.js"),
      "@paperclipai/adapter-gemini-local/ui": path.resolve(__dirname, "../packages/adapters/gemini-local/dist/ui/index.js"),
      "@paperclipai/adapter-gemini-local$": path.resolve(__dirname, "../packages/adapters/gemini-local/dist/index.js"),
      "@paperclipai/adapter-openclaw-gateway/ui": path.resolve(__dirname, "../packages/adapters/openclaw-gateway/dist/ui/index.js"),
      "@paperclipai/adapter-openclaw-gateway$": path.resolve(__dirname, "../packages/adapters/openclaw-gateway/dist/index.js"),
      "@paperclipai/adapter-opencode-local/ui": path.resolve(__dirname, "../packages/adapters/opencode-local/dist/ui/index.js"),
      "@paperclipai/adapter-opencode-local$": path.resolve(__dirname, "../packages/adapters/opencode-local/dist/index.js"),
      "@paperclipai/adapter-pi-local/ui": path.resolve(__dirname, "../packages/adapters/pi-local/dist/ui/index.js"),
      "@paperclipai/adapter-pi-local$": path.resolve(__dirname, "../packages/adapters/pi-local/dist/index.js"),
    },
  },
  build: {
    sourcemap: true,
  },
  server: {
    port: 5173,
    proxy: {
      "/api": {
        target: "http://localhost:3100",
        ws: true,
      },
    },
  },
});
