import gleam/list
import gleam/string
import lustre/dev/query.{type Query}
import lustre/element.{type Element}

pub fn view_snapshot(view: Element(msg), selector: Query) -> String {
  let elements = query.find_all(in: view, matching: selector)

  let elements_snapshot =
    elements
    |> list.map(element.to_readable_string)
    |> string.join("\n")

  "Selector: `"
  <> query.to_readable_string(selector)
  <> "`\n\n```html\n"
  <> elements_snapshot
  <> "\n```"
}
