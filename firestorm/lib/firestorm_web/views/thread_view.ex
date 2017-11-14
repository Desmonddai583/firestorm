defmodule FirestormWeb.ThreadView do
  use FirestormWeb, :view
  alias FirestormWeb.Markdown

  def markdown(body) do
    body
    |> Markdown.render
    |> raw
  end
end
