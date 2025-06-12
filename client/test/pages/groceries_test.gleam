import birdie
import client/pages/groceries
import lustre/dev/query
import lustre/dev/simulate
import shared/test_utils

pub fn add_grocery_test() {
  let app =
    simulate.simple(
      fn(_) { groceries.init() },
      groceries.update,
      groceries.view,
    )
    |> simulate.start(Nil)
    |> simulate.input(
      on: query.element(query.class("input-primary")),
      value: "Beer",
    )
    |> simulate.submit(on: query.element(query.tag("form")), fields: [])

  let selector = query.element(query.tag("li"))

  test_utils.view_snapshot(simulate.view(app), selector)
  |> birdie.snap("A grocery is added after submitting the form")
}

pub fn grocery_add_order_test() {
  let app =
    simulate.simple(
      fn(_) { groceries.init() },
      groceries.update,
      groceries.view,
    )
    |> simulate.start(Nil)
    |> simulate.input(
      on: query.element(query.class("input-primary")),
      value: "Beer",
    )
    |> simulate.submit(on: query.element(query.tag("form")), fields: [])
    |> simulate.input(
      on: query.element(query.class("input-primary")),
      value: "Snacks",
    )
    |> simulate.submit(on: query.element(query.tag("form")), fields: [])

  let selector = query.element(query.tag("li"))

  test_utils.view_snapshot(simulate.view(app), selector)
  |> birdie.snap("Groceries are added in order: Beer > Snacks")
}
