import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html.{text}
import server/component/head
import server/component/header
import wisp.{type Request, type Response}

import server/context.{type Context}

pub fn handler(ctx: Context, req: Request) -> Response {
  let html =
    head.html(ctx, [html.title([], "Contact us - Unicorn Launchpad")], [
      header.view(req),
      view(),
    ])

  wisp.ok()
  |> wisp.html_body(element.to_document_string_tree(html))
}

pub fn view() -> Element(msg) {
  html.main([class("max-w-md mx-auto my-8")], [
    html.h1([class("text-4xl font-bold")], [html.text("Contact us!")]),
    html.form([class("mt-16")], [
      //
      input("name", "Name", "What should we call you?"),
      input("email", "E-Mail", "How can we reach you?"),
      textarea("message", "Message", "Your message"),
      html.button([class("ml-auto mt-16 btn btn-primary")], [text("Send!")]),
    ]),
  ])
}

fn input(name: String, label: String, help_text: String) -> Element(msg) {
  html.fieldset([class("fieldset")], [
    html.legend([class("fieldset-legend")], [text(label)]),
    html.input([class("input w-full"), attribute.name(name)]),
    html.p([class("label")], [text(help_text)]),
  ])
}

fn textarea(name: String, label: String, help_text: String) -> Element(msg) {
  html.fieldset([class("fieldset")], [
    html.legend([class("fieldset-legend")], [text(label)]),
    html.textarea([class("textarea w-full"), attribute.name(name)], ""),
    html.p([class("label")], [text(help_text)]),
  ])
}
