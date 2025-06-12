import lustre/effect.{type Effect}
import lustre/element.{type Element}

import client/pages/flow
import client/pages/groceries
import client/pages/index
import client/route
import shared/view/error

// --- MODEL -------------------------------------------------------------------

pub opaque type Page {
  Index
  Groceries(model: groceries.Model)
  Flow(model: flow.Model)
  NotFound
}

pub fn init(route: route.Route) -> #(Page, Effect(Msg)) {
  case route {
    route.Index -> #(Index, effect.none())
    route.Groceries -> groceries.init() |> lift_model(Groceries)
    route.Flow -> flow.init() |> lift_model(Flow)
    route.NotFound -> #(NotFound, effect.none())
  }
}

// --- UPDATE ------------------------------------------------------------------

pub opaque type Msg {
  GotGroceriesMsg(msg: groceries.Msg)
  GotFlowMsg(msg: flow.Msg)
}

pub fn update(page: Page, msg: Msg) -> #(Page, Effect(Msg)) {
  case page, msg {
    Groceries(model), GotGroceriesMsg(msg) ->
      groceries.update(model, msg) |> lift_model(Groceries)

    Flow(model), GotFlowMsg(msg) -> flow.update(model, msg) |> lift_model(Flow)

    _, _ -> #(page, effect.none())
  }
}

fn lift_model(model: model, wrapper: fn(model) -> Page) -> #(Page, Effect(Msg)) {
  #(wrapper(model), effect.none())
}

// --- VIEW --------------------------------------------------------------------

pub fn view(page: Page) -> Element(Msg) {
  case page {
    Index -> index.view()
    Groceries(model) -> groceries.view(model) |> element.map(GotGroceriesMsg)
    Flow(model) -> flow.view(model) |> element.map(GotFlowMsg)
    NotFound -> error.not_found()
  }
}
