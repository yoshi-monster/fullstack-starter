import { vitePreprocess } from "@sveltejs/vite-plugin-svelte";

export default {
  compilerOptions: {
    runes: true,
    customElement: true,
  },
  // Consult https://svelte.dev/docs#compile-time-svelte-preprocess
  // for more information about preprocessors
  preprocess: vitePreprocess({ style: true, script: true }),
}
