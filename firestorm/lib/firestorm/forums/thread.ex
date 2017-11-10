defmodule Firestorm.Forums.Thread do
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.Thread


  schema "threads" do
    field :title, :string
    field :category_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Thread{} = thread, attrs) do
    thread
    |> cast(attrs, [:title, :category_id])
    |> validate_required([:title, :category_id])
  end
end
