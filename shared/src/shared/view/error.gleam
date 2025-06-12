import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html

pub fn not_found() -> Element(msg) {
  view_error("Not found!", "Maybe your prince is in another castle?")
}

pub fn bad_request() -> Element(msg) {
  view_error("Bad Request!", "Curse you, Browser!")
}

pub fn internal_server_error() -> Element(msg) {
  view_error("Uhh ohh", "Something went terribly, horribly, wrong!")
}

fn view_error(title: String, message: String) -> Element(msg) {
  html.main([class("hero bg-base-200 min-h-screen")], [
    html.div([class("hero-content text-center")], [
      html.div([class("max-w-md")], [
        //
        html.h1([class("text-5xl font-bold")], [html.text(title)]),
        html.p([class("py-6")], [html.text(message)]),
        html.a([attribute.href("/"), class("btn btn-primary")], [
          html.text("Go back home"),
        ]),
      ]),
    ]),
  ])
}
