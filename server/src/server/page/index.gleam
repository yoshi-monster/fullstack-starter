import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html
import wisp.{type Request, type Response}

import server/component/head
import server/component/header
import server/context.{type Context}

pub fn handler(ctx: Context, req: Request) -> Response {
  let html =
    head.html(ctx, [html.title([], "Unicorn Launchpad!")], [
      header.view(req),
      view(),
    ])

  wisp.ok()
  |> wisp.html_body(element.to_document_string_tree(html))
}

pub fn view() -> Element(msg) {
  html.main([class("hero bg-base-200 min-h-[80vh]")], [
    html.div([class("hero-content text-center")], [
      html.div([class("max-w-md")], [
        //
        html.h1([class("text-5xl font-bold")], [html.text("Hello, Joe!")]),
        html.p([class("py-6")], [
          html.text(
            "Accelerating tomorrows disruptive Unicorns through AI-powered innovation ecosystems and next-gen growth hacking solutions!",
          ),
        ]),
        html.a([attribute.href("/app"), class("btn btn-primary")], [
          html.text("Get started"),
        ]),
      ]),
    ]),
  ])
}
