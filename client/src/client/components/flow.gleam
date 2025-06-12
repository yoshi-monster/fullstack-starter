import gleam/dynamic/decode
import gleam/json
import lustre/attribute.{type Attribute}
import lustre/element.{type Element}
import lustre/event

// --- NODE --------------------------------------------------------------------

pub type Node {
  Default(id: String, position: Position, data: BuiltinNodeData)
  Input(id: String, position: Position, data: BuiltinNodeData)
}

fn node_decoder() -> decode.Decoder(Node) {
  use variant <- decode.field("type", decode.string)
  case variant {
    "default" -> {
      use id <- decode.field("id", decode.string)
      use position <- decode.field("position", position_decoder())
      use data <- decode.field("data", builtin_node_data_decoder())
      decode.success(Default(id:, position:, data:))
    }
    "input" -> {
      use id <- decode.field("id", decode.string)
      use position <- decode.field("position", position_decoder())
      use data <- decode.field("data", builtin_node_data_decoder())
      decode.success(Input(id:, position:, data:))
    }
    _ -> {
      let zero =
        Default(
          id: "",
          position: Position(0.0, 0.0),
          data: BuiltinNodeData(label: ""),
        )

      decode.failure(zero, "Node")
    }
  }
}

fn node_to_json(node: Node) -> json.Json {
  case node {
    Default(id:, position:, data:) ->
      json.object([
        #("type", json.string("default")),
        #("id", json.string(id)),
        #("position", position_to_json(position)),
        #("data", builtin_node_data_to_json(data)),
      ])
    Input(id:, position:, data:) ->
      json.object([
        #("type", json.string("input")),
        #("id", json.string(id)),
        #("position", position_to_json(position)),
        #("data", builtin_node_data_to_json(data)),
      ])
  }
}

pub type BuiltinNodeData {
  BuiltinNodeData(label: String)
}

fn builtin_node_data_decoder() -> decode.Decoder(BuiltinNodeData) {
  use label <- decode.field("label", decode.string)
  decode.success(BuiltinNodeData(label:))
}

fn builtin_node_data_to_json(builtin_node_data: BuiltinNodeData) -> json.Json {
  let BuiltinNodeData(label:) = builtin_node_data
  json.object([#("label", json.string(label))])
}

pub type Position {
  Position(x: Float, y: Float)
}

fn position_decoder() -> decode.Decoder(Position) {
  use x <- decode.field("x", decode.float)
  use y <- decode.field("y", decode.float)
  decode.success(Position(x:, y:))
}

fn position_to_json(position: Position) -> json.Json {
  let Position(x:, y:) = position
  json.object([#("x", json.float(x)), #("y", json.float(y))])
}

// --- EDGES -------------------------------------------------------------------

pub type Edge {
  Edge(id: String, source: String, target: String)
}

fn edge_decoder() -> decode.Decoder(Edge) {
  use id <- decode.field("id", decode.string)
  use source <- decode.field("source", decode.string)
  use target <- decode.field("target", decode.string)
  decode.success(Edge(id:, source:, target:))
}

fn edge_to_json(edge: Edge) -> json.Json {
  let Edge(id:, source:, target:) = edge
  json.object([
    #("id", json.string(id)),
    #("source", json.string(source)),
    #("target", json.string(target)),
  ])
}

// --- COMPONENT ---------------------------------------------------------------

pub fn flow(
  attributes: List(Attribute(msg)),
  nodes: List(Node),
  edges: List(Edge),
  on_change handle_change: fn(List(Node), List(Edge)) -> msg,
) -> Element(msg) {
  let decoder = {
    use nodes <- decode.subfield(
      ["detail", "nodes"],
      decode.list(node_decoder()),
    )

    use edges <- decode.subfield(
      ["detail", "edges"],
      decode.list(edge_decoder()),
    )

    decode.success(handle_change(nodes, edges))
  }

  element.element(
    "svelte-flow",
    [
      attribute.class("block"),
      attribute.property("nodes", json.array(nodes, node_to_json)),
      attribute.property("edges", json.array(edges, edge_to_json)),
      event.on("change", decoder)
        |> event.throttle(1000)
        |> event.debounce(250),
      ..attributes
    ],
    [],
  )
}
