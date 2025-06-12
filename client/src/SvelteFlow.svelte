<svelte:options
  customElement={{
    tag: 'svelte-flow',
    shadow: 'none',

	extend(svelteCustomElementClass) {
		return class extends svelteCustomElementClass {
			constructor() {
				super()
				console.log(this)
			}
		}
	},
  }}
/>

<script lang="ts">
	import { untrack } from "svelte";
	import {
		SvelteFlow,
		MiniMap,
		Controls,
		Background,
		type Node,
		type Edge
	} from "@xyflow/svelte";

	let {
		nodes: initialNodes = [],
		edges: initialEdges = []
	} = $props();

	let nodes = $state.raw<Node[]>([])
	let edges = $state.raw<Edge[]>([])

	$effect(() => {
		const nodesById = untrack(() => Object.groupBy(nodes, node => node.id));

		nodes = initialNodes.map(node =>
			node.id in nodesById ? { ...nodesById[node.id], ...node } : node);
	})

	$effect(() => {
		const edgesById = untrack(() => Object.groupBy(edges, edge => edge.id));

		edges = initialEdges.map(edge =>
			edge.id in edgesById ? { ...edgesById[edge.id], ...edge } : edge);
	})

	$effect(() => {
		$host().dispatchEvent(new CustomEvent('change', {
			bubbles: true,
			composed: true,
			detail: {
				nodes,
				edges,
			}
		}))
	})
</script>

<SvelteFlow bind:nodes bind:edges fitView>
	<MiniMap />
	<Controls />
	<Background />
</SvelteFlow>

