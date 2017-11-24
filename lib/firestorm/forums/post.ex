defmodule Firestorm.Forums.Post do
  @moduledoc """
  Schema for forum posts.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{Post, User, Thread, View}

  schema "posts" do
    field :body, :string
    field :oembeds, :any, virtual: true

    belongs_to :thread, Thread
    belongs_to :user, User
    has_many :views, {"posts_views", View}, foreign_key: :assoc_id
    many_to_many :viewers, User, join_through: "posts_views", join_keys: [assoc_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:body, :thread_id, :user_id])
    |> validate_required([:body, :thread_id, :user_id])
  end
end
