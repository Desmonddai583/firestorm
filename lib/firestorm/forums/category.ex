defmodule Firestorm.Forums.Category do
  @moduledoc """
  Schema for forum categories.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{Category, Thread}
  alias Firestorm.Forums.Slugs.CategoryTitleSlug

  schema "categories" do
    field :title, :string
    field :slug, CategoryTitleSlug.Type
    has_many :threads, Thread

    timestamps()
  end

  @doc false
  def changeset(%Category{} = category, attrs) do
    category
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> CategoryTitleSlug.maybe_generate_slug
    |> CategoryTitleSlug.unique_constraint
  end
end
