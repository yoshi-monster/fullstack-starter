import 'vite/modulepreload-polyfill'

import './SvelteFlow.svelte';

// unfortunately, Typescript integration with vite-gleam doesn't quite work as
// well as I want it to. Thankfully, we only need to call into Gleam here and
// that's it.
import { main } from './client/app.gleam';
main();
