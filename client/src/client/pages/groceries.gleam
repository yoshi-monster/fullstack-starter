import gleam/int
import gleam/list
import lustre/attribute.{class}
import lustre/element.{type Element}
import lustre/element/html.{text}
import lustre/event

// --- MODEL -------------------------------------------------------------------

pub opaque type Model {
  Model(groceries: List(Grocery), input: String, next_id: Int)
}

pub opaque type Grocery {
  Grocery(id: Int, title: String, amount: Int)
}

pub fn init() {
  Model(groceries: [], input: "", next_id: 1)
}

// --- UPDATE ------------------------------------------------------------------

pub opaque type Msg {
  UserCreatedGrocery
  UserChangedInput(title: String)
  UserChangedAmount(id: Int, amount: String)
}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserChangedInput(title:) -> Model(..model, input: title)
    UserCreatedGrocery -> {
      let grocery = Grocery(id: model.next_id, title: model.input, amount: 1)
      let groceries = list.append(model.groceries, [grocery])
      Model(groceries:, input: "", next_id: model.next_id + 1)
    }
    UserChangedAmount(id:, amount:) -> {
      case int.parse(amount) {
        Ok(amount) -> {
          let groceries =
            list.map(model.groceries, fn(grocery) {
              case grocery.id == id {
                True -> Grocery(..grocery, amount:)
                False -> grocery
              }
            })

          Model(..model, groceries:)
        }

        Error(_) -> model
      }
    }
  }
}

// --- VIEW --------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  html.div([class("max-w-md mx-auto my-8 space-y-8")], [
    html.h1([class("text-4xl font-bold")], [text("Groceries")]),
    html.form([event.on_submit(fn(_) { UserCreatedGrocery })], [
      html.input([
        class("input input-lg input-primary w-full"),
        attribute.placeholder("What do you need?"),
        attribute.value(model.input),
        event.on_input(UserChangedInput),
      ]),
    ]),
    html.ul([], list.map(model.groceries, view_grocery)),
  ])
}

fn view_grocery(grocery: Grocery) -> Element(Msg) {
  html.li([class("flex items-center")], [
    text(grocery.title),
    html.label([class("w-auto input input-sm ml-auto")], [
      text("Amount"),
      html.input([
        class("w-16"),
        attribute.type_("number"),
        attribute.value(int.to_string(grocery.amount)),
        event.on_change(UserChangedAmount(id: grocery.id, amount: _)),
      ]),
    ]),
  ])
}
