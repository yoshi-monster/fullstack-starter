import filepath
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html as h

import server/context.{type Context}

pub fn html(
  ctx: Context,
  head: List(Element(msg)),
  body: List(Element(msg)),
) -> Element(msg) {
  h.html([attribute.lang("en")], [
    h.head([], [
      h.meta([attribute.charset("utf-8")]),
      h.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1.0"),
      ]),
      h.meta([attribute.name("X-UA-Compatible"), attribute.content("ie=edge")]),
      h.link([attribute.rel("shortcut icon"), attribute.href("/favicon.svg")]),
      //
      h.title([], "Unicorn Launchpad!"),
      //
      case ctx.mode {
        context.Production | context.Test -> element.none()
        context.Development ->
          h.script(
            [
              attribute.type_("module"),
              attribute.src(filepath.join(context.vite_url, "@vite/client")),
            ],
            "",
          )
      },
      //
      entry_point(ctx, "src/main.css"),
      //
      ..head
    ]),
    h.body([], body),
  ])
}

pub fn entry_point(context: Context, name: String) -> Element(msg) {
  case context.mode {
    context.Test -> element.none()

    context.Development -> {
      let url = filepath.join(context.vite_url, name)

      case filepath.extension(name) {
        Ok("css") -> h.link([attribute.rel("stylesheet"), attribute.href(url)])

        Ok("js") | Ok("ts") ->
          h.script([attribute.type_("module"), attribute.src(url)], "")

        _ -> element.none()
      }
    }

    context.Production -> {
      let assert Ok(entry_point_files) =
        context.get_entry_point(context.manifest, name)

      element.fragment({
        use entry_point_file <- list.map(entry_point_files)
        let entry_point_file = "/" <> entry_point_file

        case filepath.extension(entry_point_file) {
          Ok("css") ->
            h.link([
              attribute.rel("stylesheet"),
              attribute.href(entry_point_file),
            ])

          Ok("js") -> h.script([attribute.src(entry_point_file)], "")

          _ -> element.none()
        }
      })
    }
  }
}
