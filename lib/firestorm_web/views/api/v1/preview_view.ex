defmodule FirestormWeb.Api.V1.PreviewView do
  use FirestormWeb, :view

  def render("show.json", %{html: html}) do
    %{data: %{ html: html } }
  end
end