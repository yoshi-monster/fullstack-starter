import gleam/dynamic/decode
import gleam/json
import gleam/result
import gleam/uri
import lustre
import lustre/attribute.{class}
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html.{text}
import modem
import plinth/browser/document
import plinth/browser/element as plinth_element

import client/page
import client/route

// --- ARGS --------------------------------------------------------------------

pub type Args {
  Args(base_path: String)
}

pub fn args_to_json(args: Args) -> json.Json {
  let Args(base_path:) = args
  json.object([#("base_path", json.string(base_path))])
}

pub fn args_decoder() -> decode.Decoder(Args) {
  use base_path <- decode.field("base_path", decode.string)
  decode.success(Args(base_path:))
}

fn get_args_from_element(selector: String) {
  use args_el <- result.try(document.query_selector(selector))
  let inner_text = plinth_element.inner_text(args_el)

  json.parse(inner_text, using: args_decoder())
  |> result.replace_error(Nil)
}

// --- MAIN --------------------------------------------------------------------

pub fn main() {
  let assert Ok(args) = get_args_from_element("#model")
  let assert Ok(initial_url) = modem.initial_uri()

  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", #(args, initial_url))

  Nil
}

// --- MODEL -------------------------------------------------------------------

type Model {
  Model(base_path: String, route: route.Route, page: page.Page)
}

fn init(flags: #(Args, uri.Uri)) -> #(Model, Effect(Msg)) {
  let #(args, initial_uri) = flags
  let route = route.parse(args.base_path, initial_uri)

  let #(page, page_effects) = page.init(route)

  let model = Model(base_path: args.base_path, route:, page:)
  let effects =
    effect.batch([
      effect.map(page_effects, GotPageMsg),
      modem.init(UserChangedUrl),
    ])

  #(model, effects)
}

// --- UPDATE ------------------------------------------------------------------

type Msg {
  UserChangedUrl(url: uri.Uri)
  GotPageMsg(msg: page.Msg)
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserChangedUrl(url) -> {
      let route = route.parse(model.base_path, url)
      let #(page, page_effects) = page.init(route)

      #(Model(..model, route:, page:), effect.map(page_effects, GotPageMsg))
    }

    GotPageMsg(msg) -> {
      let #(page, page_effects) = page.update(model.page, msg)

      #(Model(..model, page:), effect.map(page_effects, GotPageMsg))
    }
  }
}

// --- VIEW --------------------------------------------------------------------

fn view(model: Model) {
  element.fragment([
    view_header(model.base_path, model.route),
    page.view(model.page)
      |> element.map(GotPageMsg),
  ])
}

fn view_header(base_path: String, route: route.Route) -> Element(msg) {
  html.div([class("navbar flex bg-base-100 shadow-sm")], [
    html.div([class("flex-1")], [
      html.a(
        [route.href(base_path, route.Index), class("btn btn-ghost text-xl")],
        [
          html.img([
            attribute.src("/favicon.svg"),
            attribute.class("h-full aspect-square p-1 mr-2"),
          ]),
          text("Unicorn Launchpad"),
        ],
      ),
    ]),
    html.div([class("flex-none")], [
      html.ul([class("menu menu-horizontal px-1")], [
        view_nav_item(base_path, route, route.Groceries, "Groceries"),
        view_nav_item(base_path, route, route.Flow, "Flow Builder"),
      ]),
    ]),
  ])
}

fn view_nav_item(
  base_path: String,
  current: route.Route,
  target: route.Route,
  title: String,
) {
  let active = current == target

  html.li([], [
    html.a(
      [
        attribute.classes([#("menu-active", active)]),
        route.href(base_path, target),
      ],
      [text(title)],
    ),
  ])
}
