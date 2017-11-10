defmodule Firestorm.Forums.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.Post


  schema "posts" do
    field :body, :string
    field :thread_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:body, :thread_id, :user_id])
    |> validate_required([:body, :thread_id, :user_id])
  end
end
