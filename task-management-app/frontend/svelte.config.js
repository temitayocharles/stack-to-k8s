import adapter from '@sveltejs/adapter-node';
import { vitePreprocess } from '@sveltejs/kit/vite';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  // Consult https://kit.svelte.dev/docs/integrations#preprocessors
  // for more information about preprocessors
  preprocess: vitePreprocess(),

  kit: {
    // adapter-auto only supports some environments, see https://kit.svelte.dev/docs/adapter-auto for a list.
    // If your environment is not supported or you settled on a specific environment, switch out the adapter.
    // See https://kit.svelte.dev/docs/adapters for more information about adapters.
    adapter: adapter({
      // default options are shown
      out: 'build',
      precompress: false,
      envPrefix: ''
    }),
    
    // App configuration
    appDir: '_app',
    paths: {
      base: '',
      assets: ''
    },
    
    // Enable service worker for offline support
    serviceWorker: {
      register: true
    },
    
    // Alias configuration for imports
    alias: {
      $components: 'src/lib/components',
      $stores: 'src/lib/stores',
      $utils: 'src/lib/utils',
      $types: 'src/lib/types',
      $api: 'src/lib/api'
    },
    
    // Version configuration
    version: {
      name: process.env.npm_package_version,
      pollInterval: 0
    },
    
    // Embedded configuration
    embedded: false,
    
    // Trust proxy for production deployment
    trustProxy: process.env.NODE_ENV === 'production',
    
    // CSRF protection
    csrf: {
      checkOrigin: process.env.NODE_ENV === 'production'
    }
  }
};

export default config;
