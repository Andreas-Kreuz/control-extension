import react from '@vitejs/plugin-react';
import { fileURLToPath, URL } from 'node:url';
import { defineConfig, searchForWorkspaceRoot } from 'vite';

const webSharedSource = fileURLToPath(new URL('../web-shared/src/index.ts', import.meta.url));
const webAppRoot = fileURLToPath(new URL('.', import.meta.url));
const webSharedRoot = fileURLToPath(new URL('../web-shared', import.meta.url));

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@ce/web-shared': webSharedSource,
    },
  },
  server: {
    fs: {
      allow: [searchForWorkspaceRoot(process.cwd()), webAppRoot, webSharedRoot],
    },
  },
});
