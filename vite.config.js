import { defineConfig } from 'vite';
import path from 'path';
import tailwindcss from '@tailwindcss/vite';
import viteCompression from 'vite-plugin-compression';

export default defineConfig({
  plugins: [
    // Tailwind CSS v4
    tailwindcss(),
    // Compression Gzip et Brotli
    viteCompression({
      verbose: true,
      disable: false,
      threshold: 10240,
      algorithm: 'gzip',
      ext: '.gz',
    }),
    viteCompression({
      verbose: true,
      disable: false,
      threshold: 10240,
      algorithm: 'brotliCompress',
      ext: '.br',
    }),
  ],
  base: '/static/',
  build: {
    outDir: path.resolve(__dirname, './static'),
    emptyOutDir: false,
    manifest: 'manifest.json',
    // Minification optimale
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true,
        pure_funcs: ['console.log'],
      },
    },
    rollupOptions: {
      input: {
        index: path.resolve(__dirname, './assets/index.js'),
        style: path.resolve(__dirname, './assets/style.css'),
      },
      output: {
        entryFileNames: 'js/[name]-[hash].js',
        chunkFileNames: 'js/[name]-[hash].js',
        assetFileNames: (assetInfo) => {
          if (assetInfo.name.endsWith('.css')) {
            return 'css/[name]-[hash][extname]';
          }
          return 'assets/[name]-[hash][extname]';
        },
        // Code splitting pour optimiser le chargement
        manualChunks: {
          htmx: ['htmx.org'],
          alpine: ['alpinejs'],
        },
      },
    },
    // Optimisations supplémentaires
    cssCodeSplit: true,
    sourcemap: false,
    reportCompressedSize: true,
    chunkSizeWarningLimit: 500,
  },
  optimizeDeps: {
    include: ['htmx.org', 'alpinejs'],
  },
});