import path from "path";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  plugins: [react(), tailwindcss()],
  optimizeDeps: {
    include: [
      '@paperclipai/adapter-claude-local',
      '@paperclipai/adapter-codex-local',
      '@paperclipai/adapter-cursor-local',
      '@paperclipai/adapter-gemini-local',
      '@paperclipai/adapter-openclaw-gateway',
      '@paperclipai/adapter-opencode-local',
      '@paperclipai/adapter-pi-local',
      '@paperclipai/adapter-utils',
      '@paperclipai/shared',
    ],
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
      lexical: path.resolve(__dirname, "./node_modules/lexical/Lexical.mjs"),
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
