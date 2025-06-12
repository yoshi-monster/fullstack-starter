import gleam/list
import gleam/string
import gleam/uri
import lustre/attribute.{type Attribute}

pub type Route {
  Index
  Groceries
  Flow
  NotFound
}

pub fn parse(base_path: String, url: uri.Uri) {
  let base_segments = uri.path_segments(base_path)
  let url_segments = uri.path_segments(url.path)
  case consume_base_path(base_segments, url_segments) {
    Ok([""]) | Ok([]) -> Index
    Ok(["groceries"]) -> Groceries
    Ok(["flow"]) -> Flow
    _ -> NotFound
  }
}

fn consume_base_path(base_segments, url_segments) {
  case base_segments, url_segments {
    [base_segment, ..base_rest], [url_segment, ..url_rest]
      if base_segment == url_segment
    -> consume_base_path(base_rest, url_rest)

    [], _ -> Ok(url_segments)

    _, _ -> Error(Nil)
  }
}

// --- VIEW --------------------------------------------------------------------

pub fn href(base_path: String, route: Route) -> Attribute(msg) {
  attribute.href(path(base_path, route))
}

pub fn path(base_path: String, route: Route) -> String {
  let relative = case route {
    Index -> []
    Groceries -> ["groceries"]
    Flow -> ["flow"]
    NotFound -> ["404"]
  }

  let segments = uri.path_segments(base_path) |> list.append(relative)

  "/" <> string.join(segments, with: "/")
}
