import { defineConfig, type Plugin } from 'vite'

import { svelte } from '@sveltejs/vite-plugin-svelte'
import gleam from 'vite-gleam'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    svelte(),
    // cast is required because vite-gleam depends on vite@4, but we use vite@6
    // this is fine I promise
    gleam() as unknown as Promise<Plugin>,
    tailwindcss()
  ],

  server: {
   cors: {
    origin: 'http://localhost:3000'
   }
  },

  // instead of using publicDir, place files inside server/priv/static
  publicDir: false,

  build: {
   outDir: './priv/static/',
   emptyOutDir: true,
   // generate a .vite/manifest.json in outDir
   manifest: true,
   rollupOptions: {
    // overwrite default .html entry
    input: [
     './src/main.js',
     './src/main.css'
    ]
   }
  }
})
