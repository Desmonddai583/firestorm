defmodule Firestorm.Forums.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{Post, User, Thread}

  schema "posts" do
    field :body, :string

    belongs_to :thread, Thread
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:body, :thread_id, :user_id])
    |> validate_required([:body, :thread_id, :user_id])
  end
end
