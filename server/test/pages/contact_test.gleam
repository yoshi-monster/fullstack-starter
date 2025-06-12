import birdie
import lustre/dev/query
import server/page/contact
import shared/test_utils

pub fn contact_contains_a_send_button_test() {
  let html = contact.view()

  let selector =
    query.element(query.tag("form"))
    |> query.descendant(query.class("btn-primary"))

  test_utils.view_snapshot(html, selector)
  |> birdie.snap("The contact form has to contain a Send button")
}
