import gleam/int
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event

import client/components/flow.{type Edge, type Node}

// --- MODEL -------------------------------------------------------------------

pub opaque type Model {
  Model(nodes: List(Node), edges: List(Edge), next_id: Int)
}

pub fn init() -> Model {
  Model(nodes: [], edges: [], next_id: 1)
}

// --- UPDATE ------------------------------------------------------------------

pub type Msg {
  UserClickedAdd
  UserChangedScene(nodes: List(Node), edges: List(Edge))
}

pub fn update(model: Model, msg: Msg) -> Model {
  case echo msg {
    UserClickedAdd -> {
      let id = int.to_string(model.next_id)
      let node =
        flow.Default(
          id: int.to_string(model.next_id),
          position: flow.Position(0.0, 0.0),
          data: flow.BuiltinNodeData(label: "Node " <> id),
        )
      Model(..model, nodes: [node, ..model.nodes], next_id: model.next_id + 1)
    }

    UserChangedScene(nodes:, edges:) -> Model(..model, nodes:, edges:)
  }
}

// --- VIEW --------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  element.fragment([
    html.div([attribute.class("mx-8 my-4")], [
      html.button(
        [attribute.class("btn btn-primary"), event.on_click(UserClickedAdd)],
        [html.text("Add a node")],
      ),
    ]),
    flow.flow(
      [attribute.class("h-[80vh]")],
      model.nodes,
      model.edges,
      UserChangedScene,
    ),
  ])
}
