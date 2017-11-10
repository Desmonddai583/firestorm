defmodule Firestorm.Forums.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.Category


  schema "categories" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
