import gleam/string
import lustre/attribute.{class}
import lustre/element/html.{text}
import wisp

pub fn view(req: wisp.Request) {
  html.div([class("navbar flex bg-base-100 shadow-sm")], [
    html.div([class("flex-1")], [
      html.a([attribute.href("/"), class("btn btn-ghost text-xl")], [
        html.img([
          attribute.src("/favicon.svg"),
          attribute.class("h-full aspect-square p-1 mr-2"),
        ]),
        text("Unicorn Launchpad"),
      ]),
    ]),
    html.div([class("flex-none")], [
      html.ul([class("menu menu-horizontal px-1")], [
        view_nav_item(req, "/contact", "Contact us"),
        view_nav_item(req, "/app", "Go to App ↗"),
      ]),
    ]),
  ])
}

fn view_nav_item(req: wisp.Request, link: String, title: String) {
  let active = string.starts_with(req.path, link)

  html.li([], [
    html.a(
      [attribute.classes([#("menu-active", active)]), attribute.href(link)],
      [text(title)],
    ),
  ])
}
