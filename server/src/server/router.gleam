import gleam/bool
import server/context.{type Context}
import wisp.{type Request, type Response}

// import server/api
import server/page/app
import server/page/contact
import server/page/error
import server/page/index

pub fn handle_request(ctx: Context, req: Request) -> Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  use <- default_responses(ctx)

  use <- wisp.serve_static(req, under: "", from: ctx.server_static)
  use <- wisp.serve_static(req, under: "", from: ctx.client_static)

  case wisp.path_segments(req) {
    [] | [""] -> index.handler(ctx, req)
    ["contact"] -> contact.handler(ctx, req)
    ["app", ..] -> app.handler(ctx, req)
    // ["api", ..] -> api.handler(ctx, req)
    _ -> wisp.not_found()
  }
}

fn default_responses(ctx: Context, handle_request: fn() -> Response) -> Response {
  let response = handle_request()
  use <- bool.guard(when: response.body != wisp.Empty, return: response)

  case response.status {
    404 | 405 -> error.not_found(ctx)
    400 | 413 | 422 -> error.bad_request(ctx)
    500 -> error.internal_server_error(ctx)
    _ -> response
  }
}
