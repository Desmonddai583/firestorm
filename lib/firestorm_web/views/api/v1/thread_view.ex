defmodule FirestormWeb.Api.V1.ThreadView do
  use FirestormWeb, :view
  alias Firestorm.Forums.Thread

  def render("show.json", %Thread{id: id, title: title, inserted_at: inserted_at, updated_at: updated_at, category_id: category_id, slug: slug}) do
    %{
      id: id,
      title: title,
      slug: slug,
      inserted_at: inserted_at,
      updated_at: updated_at,
      category_id: category_id
    }
  end
end