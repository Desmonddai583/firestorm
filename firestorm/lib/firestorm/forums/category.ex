defmodule Firestorm.Forums.Category do
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{Category, Thread}

  schema "categories" do
    field :title, :string
    has_many :threads, Thread

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
