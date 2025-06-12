import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html

pub fn view() -> Element(msg) {
  html.main([class("hero bg-base-200 min-h-[80vh]")], [
    html.div([class("hero-content text-center")], [
      html.div([class("max-w-md")], [
        //
        html.h1([class("text-5xl font-bold")], [
          html.text("Hello, from Lustre!"),
        ]),
        html.p([class("py-6")], [
          html.text("This is a Lustre SPA embedded into a bigger Wisp MPA."),
        ]),
      ]),
    ]),
  ])
}
