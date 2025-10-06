/// <reference types="vite/client" />

declare const process: any;

import react from "@vitejs/plugin-react";
import { defineConfig, loadEnv } from "vite";

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  // carrega variáveis de ambiente do .env* corretamente
  const env = loadEnv(mode, process.cwd(), "");
  const port = Number(env.PORT) || 5174;

  return {
    plugins: [react()],
    base: "./",
    server: {
      port,
      strictPort: false,
    },
  };
});
