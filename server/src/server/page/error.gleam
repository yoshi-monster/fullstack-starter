import lustre/element.{type Element}
import lustre/element/html
import wisp.{type Response}

import server/component/head
import server/context.{type Context}
import shared/view/error

pub fn not_found(ctx: Context) -> Response {
  error.not_found() |> handle(ctx)
}

pub fn bad_request(ctx: Context) -> Response {
  error.bad_request() |> handle(ctx)
}

pub fn internal_server_error(ctx: Context) -> Response {
  error.internal_server_error() |> handle(ctx)
}

fn handle(view: Element(msg), ctx: Context) -> Response {
  let html =
    head.html(ctx, [html.title([], "Error - Unicorn Launchpad")], [view])

  wisp.ok()
  |> wisp.html_body(element.to_document_string_tree(html))
}
