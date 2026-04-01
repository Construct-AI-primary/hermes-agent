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
