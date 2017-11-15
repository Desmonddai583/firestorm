defmodule Page.Thread.New do
  import Wallaby.Query

  # We'll use the field ids as our selector
  def title_field(), do: text_field("thread_title")
  # There's no `text_area` function. We can just use `fillable_field`. We could
  # also use `text_field` but this isn't actually a text field so our tests
  # would be lying a bit.
  def body_field(), do: fillable_field("thread_body")
  def create_thread_button(), do: button("Create Thread")
end