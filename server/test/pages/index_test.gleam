import birdie
import lustre/dev/query
import server/page/index
import shared/test_utils

pub fn index_slogan_test() {
  let html = index.view()

  let selector =
    query.element(query.class("hero-content"))
    |> query.descendant(query.tag("p"))

  test_utils.view_snapshot(html, selector)
  |> birdie.snap("The hero section contains a relevant slogan")
}

pub fn index_cta_test() {
  let html = index.view()

  let selector =
    query.element(query.class("hero-content"))
    |> query.descendant(query.class("btn-primary"))

  test_utils.view_snapshot(html, selector)
  |> birdie.snap("The hero section contains an engaging CTA")
}
