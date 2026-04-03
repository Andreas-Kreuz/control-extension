import react from '@vitejs/plugin-react';
import { defineConfig } from 'vite';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    // We need to include all libraries manually
    include: ['@ce/web-shared'],
    // exclude: [],
  },
  build: {
    commonjsOptions: {
      include: ['@ce/web-shared'],
      // exclude: [],
    },
  },
});

