import gleam/json
import lustre/attribute
import lustre/element
import lustre/element/html
import wisp.{type Request, type Response}

import client/app
import server/component/head
import server/context.{type Context}

pub fn handler(ctx: Context, _req: Request) -> Response {
  let args = app.Args(base_path: "/app")
  let serialised_args = args |> app.args_to_json |> json.to_string

  let html =
    head.html(
      ctx,
      [
        html.title([], "Unicorn Launchpad!"),
        head.entry_point(ctx, "src/main.js"),
        html.script(
          [attribute.id("model"), attribute.type_("application/json")],
          serialised_args,
        ),
      ],
      [html.main([attribute.id("app"), attribute.class("min-h-screen")], [])],
    )

  wisp.ok()
  |> wisp.html_body(element.to_document_string_tree(html))
}
