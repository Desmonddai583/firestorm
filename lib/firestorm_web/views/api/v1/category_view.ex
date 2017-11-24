defmodule FirestormWeb.Api.V1.CategoryView do
  use FirestormWeb, :view
  alias Firestorm.Forums.Category

  def render("show.json", %Category{id: id, title: title, slug: slug, inserted_at: inserted_at, updated_at: updated_at}) do
    %{
      id: id,
      title: title,
      slug: slug,
      inserted_at: inserted_at,
      updated_at: updated_at
    }
  end
end