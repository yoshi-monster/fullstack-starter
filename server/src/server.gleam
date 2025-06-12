import envoy
import filepath
import gleam/erlang/process
import gleam/int
import gleam/json
import gleam/result
import mist
import simplifile
import wisp
import wisp/wisp_mist

import server/context.{Context}
import server/router

pub fn main() -> Nil {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)

  let assert Ok(port) =
    envoy.get("PORT")
    |> result.then(int.parse)

  let mode = case envoy.get("MODE") {
    Ok("production") -> context.Production
    _ -> context.Development
  }

  let assert Ok(client_static) =
    wisp.priv_directory("client")
    |> result.map(filepath.join(_, "static"))

  let assert Ok(server_static) =
    wisp.priv_directory("server")
    |> result.map(filepath.join(_, "static"))

  let manifest = case
    simplifile.read(filepath.join(client_static, ".vite/manifest.json"))
  {
    Ok(manifest_json) -> {
      let assert Ok(manifest) =
        json.parse(manifest_json, context.manifest_decoder())

      manifest
    }

    Error(_) if mode == context.Development -> context.empty_manifest()
    Error(_) -> panic as "Could not read manifest.json"
  }

  let ctx = Context(mode:, client_static:, server_static:, manifest:)

  let assert Ok(_) =
    wisp_mist.handler(router.handle_request(ctx, _), secret_key_base)
    |> mist.new
    |> mist.port(port)
    |> mist.bind("0.0.0.0")
    |> mist.start_http

  process.sleep_forever()
}
