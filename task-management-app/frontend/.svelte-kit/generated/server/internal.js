
import root from '../root.svelte';
import { set_building, set_prerendering } from '__sveltekit/environment';
import { set_assets } from '__sveltekit/paths';
import { set_manifest, set_read_implementation } from '__sveltekit/server';
import { set_private_env, set_public_env } from '../../../node_modules/@sveltejs/kit/src/runtime/shared-server.js';

export const options = {
	app_template_contains_nonce: false,
	csp: {"mode":"auto","directives":{"upgrade-insecure-requests":false,"block-all-mixed-content":false},"reportOnly":{"upgrade-insecure-requests":false,"block-all-mixed-content":false}},
	csrf_check_origin: true,
	csrf_trusted_origins: [],
	embedded: false,
	env_public_prefix: 'PUBLIC_',
	env_private_prefix: '',
	hash_routing: false,
	hooks: null, // added lazily, via `get_hooks`
	preload_strategy: "modulepreload",
	root,
	service_worker: false,
	service_worker_options: undefined,
	templates: {
		app: ({ head, body, assets, nonce, env }) => "<!DOCTYPE html>\n<html lang=\"en\" %sveltekit.theme%>\n  <head>\n    <meta charset=\"utf-8\" />\n    <link rel=\"icon\" href=\"" + assets + "/favicon.png\" />\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n    <meta name=\"description\" content=\"TaskFlow - Professional Task Management Application\" />\n    <meta name=\"keywords\" content=\"task management, productivity, project management, team collaboration\" />\n    <meta name=\"author\" content=\"TaskFlow Team\" />\n    \n    <!-- Open Graph Meta Tags -->\n    <meta property=\"og:title\" content=\"TaskFlow - Task Management App\" />\n    <meta property=\"og:description\" content=\"Streamline your workflow with our professional task management solution\" />\n    <meta property=\"og:type\" content=\"website\" />\n    <meta property=\"og:url\" content=\"https://taskflow.app\" />\n    <meta property=\"og:image\" content=\"" + assets + "/og-image.png\" />\n    \n    <!-- Twitter Card Meta Tags -->\n    <meta name=\"twitter:card\" content=\"summary_large_image\" />\n    <meta name=\"twitter:title\" content=\"TaskFlow - Task Management App\" />\n    <meta name=\"twitter:description\" content=\"Streamline your workflow with our professional task management solution\" />\n    <meta name=\"twitter:image\" content=\"" + assets + "/twitter-image.png\" />\n    \n    <!-- PWA Configuration -->\n    <link rel=\"manifest\" href=\"" + assets + "/manifest.json\" />\n    <meta name=\"theme-color\" content=\"#3b82f6\" />\n    <meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />\n    <meta name=\"apple-mobile-web-app-status-bar-style\" content=\"default\" />\n    <meta name=\"apple-mobile-web-app-title\" content=\"TaskFlow\" />\n    <link rel=\"apple-touch-icon\" href=\"" + assets + "/apple-touch-icon.png\" />\n    \n    <!-- Security Headers -->\n    <meta http-equiv=\"X-Content-Type-Options\" content=\"nosniff\" />\n    <meta http-equiv=\"X-Frame-Options\" content=\"DENY\" />\n    <meta http-equiv=\"X-XSS-Protection\" content=\"1; mode=block\" />\n    <meta http-equiv=\"Referrer-Policy\" content=\"strict-origin-when-cross-origin\" />\n    \n    <!-- Preconnect to external domains -->\n    <link rel=\"preconnect\" href=\"https://fonts.googleapis.com\" />\n    <link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin />\n    \n    <!-- Google Fonts -->\n    <link\n      href=\"https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap\"\n      rel=\"stylesheet\"\n    />\n    \n    <!-- Load critical CSS -->\n    <style>\n      /* Critical CSS for initial paint */\n      * {\n        box-sizing: border-box;\n      }\n      \n      html {\n        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;\n        line-height: 1.5;\n        -webkit-text-size-adjust: 100%;\n        -webkit-font-smoothing: antialiased;\n        -moz-osx-font-smoothing: grayscale;\n      }\n      \n      body {\n        margin: 0;\n        padding: 0;\n        min-height: 100vh;\n        background-color: #f8fafc;\n        color: #1e293b;\n      }\n      \n      /* Loading spinner styles */\n      .app-loading {\n        display: flex;\n        align-items: center;\n        justify-content: center;\n        min-height: 100vh;\n        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n      }\n      \n      .loading-spinner {\n        width: 50px;\n        height: 50px;\n        border: 3px solid rgba(255, 255, 255, 0.3);\n        border-radius: 50%;\n        border-top-color: white;\n        animation: spin 1s ease-in-out infinite;\n      }\n      \n      @keyframes spin {\n        to { transform: rotate(360deg); }\n      }\n      \n      .loading-text {\n        color: white;\n        margin-top: 20px;\n        font-size: 16px;\n        font-weight: 500;\n      }\n      \n      /* Hide loading when app is ready */\n      .app-ready .app-loading {\n        display: none;\n      }\n    </style>\n    \n    " + head + "\n  </head>\n  \n  <body data-sveltekit-preload-data=\"hover\" class=\"app-loading\">\n    <!-- Loading screen -->\n    <div class=\"app-loading\">\n      <div>\n        <div class=\"loading-spinner\"></div>\n        <div class=\"loading-text\">Loading TaskFlow...</div>\n      </div>\n    </div>\n    \n    <!-- Main app container -->\n    <div style=\"display: contents\">" + body + "</div>\n    \n    <!-- Service Worker Registration -->\n    <script>\n      // Register service worker for offline functionality\n      if ('serviceWorker' in navigator && location.protocol === 'https:') {\n        navigator.serviceWorker.register('/service-worker.js')\n          .then(registration => {\n            console.log('SW registered: ', registration);\n          })\n          .catch(registrationError => {\n            console.log('SW registration failed: ', registrationError);\n          });\n      }\n      \n      // Remove loading screen when app is ready\n      document.addEventListener('DOMContentLoaded', () => {\n        setTimeout(() => {\n          document.body.classList.add('app-ready');\n        }, 100);\n      });\n      \n      // Error boundary for unhandled JavaScript errors\n      window.addEventListener('error', (event) => {\n        console.error('Global error:', event.error);\n        // You can send error reports to your monitoring service here\n      });\n      \n      window.addEventListener('unhandledrejection', (event) => {\n        console.error('Unhandled promise rejection:', event.reason);\n        // You can send error reports to your monitoring service here\n      });\n    </script>\n  </body>\n</html>\n",
		error: ({ status, message }) => "<!doctype html>\n<html lang=\"en\">\n\t<head>\n\t\t<meta charset=\"utf-8\" />\n\t\t<title>" + message + "</title>\n\n\t\t<style>\n\t\t\tbody {\n\t\t\t\t--bg: white;\n\t\t\t\t--fg: #222;\n\t\t\t\t--divider: #ccc;\n\t\t\t\tbackground: var(--bg);\n\t\t\t\tcolor: var(--fg);\n\t\t\t\tfont-family:\n\t\t\t\t\tsystem-ui,\n\t\t\t\t\t-apple-system,\n\t\t\t\t\tBlinkMacSystemFont,\n\t\t\t\t\t'Segoe UI',\n\t\t\t\t\tRoboto,\n\t\t\t\t\tOxygen,\n\t\t\t\t\tUbuntu,\n\t\t\t\t\tCantarell,\n\t\t\t\t\t'Open Sans',\n\t\t\t\t\t'Helvetica Neue',\n\t\t\t\t\tsans-serif;\n\t\t\t\tdisplay: flex;\n\t\t\t\talign-items: center;\n\t\t\t\tjustify-content: center;\n\t\t\t\theight: 100vh;\n\t\t\t\tmargin: 0;\n\t\t\t}\n\n\t\t\t.error {\n\t\t\t\tdisplay: flex;\n\t\t\t\talign-items: center;\n\t\t\t\tmax-width: 32rem;\n\t\t\t\tmargin: 0 1rem;\n\t\t\t}\n\n\t\t\t.status {\n\t\t\t\tfont-weight: 200;\n\t\t\t\tfont-size: 3rem;\n\t\t\t\tline-height: 1;\n\t\t\t\tposition: relative;\n\t\t\t\ttop: -0.05rem;\n\t\t\t}\n\n\t\t\t.message {\n\t\t\t\tborder-left: 1px solid var(--divider);\n\t\t\t\tpadding: 0 0 0 1rem;\n\t\t\t\tmargin: 0 0 0 1rem;\n\t\t\t\tmin-height: 2.5rem;\n\t\t\t\tdisplay: flex;\n\t\t\t\talign-items: center;\n\t\t\t}\n\n\t\t\t.message h1 {\n\t\t\t\tfont-weight: 400;\n\t\t\t\tfont-size: 1em;\n\t\t\t\tmargin: 0;\n\t\t\t}\n\n\t\t\t@media (prefers-color-scheme: dark) {\n\t\t\t\tbody {\n\t\t\t\t\t--bg: #222;\n\t\t\t\t\t--fg: #ddd;\n\t\t\t\t\t--divider: #666;\n\t\t\t\t}\n\t\t\t}\n\t\t</style>\n\t</head>\n\t<body>\n\t\t<div class=\"error\">\n\t\t\t<span class=\"status\">" + status + "</span>\n\t\t\t<div class=\"message\">\n\t\t\t\t<h1>" + message + "</h1>\n\t\t\t</div>\n\t\t</div>\n\t</body>\n</html>\n"
	},
	version_hash: "1jrekrj"
};

export async function get_hooks() {
	let handle;
	let handleFetch;
	let handleError;
	let handleValidationError;
	let init;
	

	let reroute;
	let transport;
	

	return {
		handle,
		handleFetch,
		handleError,
		handleValidationError,
		init,
		reroute,
		transport
	};
}

export { set_assets, set_building, set_manifest, set_prerendering, set_private_env, set_public_env, set_read_implementation };
