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
      // Direct alias for workspace packages since ts files aren't resolved via exports
      "@paperclipai/adapter-utils": path.resolve(__dirname, "../packages/adapter-utils/src/index.ts"),
      "@paperclipai/shared": path.resolve(__dirname, "../packages/shared/src/index.ts"),
      // Direct aliases for all 7 adapter packages (both main and subpath exports)
      "@paperclipai/adapter-claude-local": path.resolve(__dirname, "../packages/adapters/claude-local/src/index.ts"),
      "@paperclipai/adapter-claude-local/ui": path.resolve(__dirname, "../packages/adapters/claude-local/src/ui/index.ts"),
      "@paperclipai/adapter-codex-local": path.resolve(__dirname, "../packages/adapters/codex-local/src/index.ts"),
      "@paperclipai/adapter-codex-local/ui": path.resolve(__dirname, "../packages/adapters/codex-local/src/ui/index.ts"),
      "@paperclipai/adapter-cursor-local": path.resolve(__dirname, "../packages/adapters/cursor-local/src/index.ts"),
      "@paperclipai/adapter-cursor-local/ui": path.resolve(__dirname, "../packages/adapters/cursor-local/src/ui/index.ts"),
      "@paperclipai/adapter-gemini-local": path.resolve(__dirname, "../packages/adapters/gemini-local/src/index.ts"),
      "@paperclipai/adapter-gemini-local/ui": path.resolve(__dirname, "../packages/adapters/gemini-local/src/ui/index.ts"),
      "@paperclipai/adapter-openclaw-gateway": path.resolve(__dirname, "../packages/adapters/openclaw-gateway/src/index.ts"),
      "@paperclipai/adapter-openclaw-gateway/ui": path.resolve(__dirname, "../packages/adapters/openclaw-gateway/src/ui/index.ts"),
      "@paperclipai/adapter-opencode-local": path.resolve(__dirname, "../packages/adapters/opencode-local/src/index.ts"),
      "@paperclipai/adapter-opencode-local/ui": path.resolve(__dirname, "../packages/adapters/opencode-local/src/ui/index.ts"),
      "@paperclipai/adapter-pi-local": path.resolve(__dirname, "../packages/adapters/pi-local/src/index.ts"),
      "@paperclipai/adapter-pi-local/ui": path.resolve(__dirname, "../packages/adapters/pi-local/src/ui/index.ts"),
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
