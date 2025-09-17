import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
  plugins: [sveltekit()],
  
  define: {
    // Global compile-time constants
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version || '1.0.0'),
    __BUILD_TIME__: JSON.stringify(new Date().toISOString())
  },
  
  server: {
    port: 3001,
    host: true,
    cors: true,
    proxy: {
      '/api': {
        target: process.env.VITE_API_URL || 'http://localhost:3000',
        changeOrigin: true,
        secure: false
      }
    }
  },
  
  preview: {
    port: 3001,
    host: true
  },
  
  build: {
    target: 'esnext',
    outDir: 'build',
    assetsDir: 'assets',
    sourcemap: true,
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['svelte', '@sveltejs/kit'],
          ui: ['@floating-ui/dom', 'lucide-svelte'],
          utils: ['date-fns', 'clsx']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  },
  
  resolve: {
    alias: {
      $lib: path.resolve('./src/lib'),
      $components: path.resolve('./src/lib/components'),
      $stores: path.resolve('./src/lib/stores'),
      $utils: path.resolve('./src/lib/utils'),
      $types: path.resolve('./src/lib/types'),
      $api: path.resolve('./src/lib/api')
    }
  },
  
  css: {
    preprocessorOptions: {
      scss: {
        additionalData: `@import '$lib/styles/variables.scss';`
      }
    }
  },
  
  optimizeDeps: {
    include: ['svelte', '@sveltejs/kit', 'date-fns', 'clsx'],
    exclude: ['@sveltejs/kit/app']
  }
});
