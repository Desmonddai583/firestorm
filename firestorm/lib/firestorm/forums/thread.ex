defmodule Firestorm.Forums.Thread do
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{Thread, Category, Post}

  schema "threads" do
    field :title, :string

    belongs_to :category, Category
    has_many :posts, Post

    timestamps()
  end

  @doc false
  def changeset(%Thread{} = thread, attrs) do
    thread
    |> cast(attrs, [:title, :category_id])
    |> validate_required([:title, :category_id])
  end

  def new_thread_changeset(%{thread: thread_attrs, post: post_attrs}) do
    # First we'll generate a post changeset - we don't require a thread_id here
    # because we'll build it momentarily and it's impossible to know.
    post_changeset =
      %Post{}
      |> cast(post_attrs, [:body, :user_id])
      |> validate_required([:body, :user_id])

    # Then we'll build our thread changeset like before, but we'll put a new
    # associated post into the changeset. There's only one post since it's the
    # first one, so we make a new list with just our one post in it.
    %Thread{}
    |> Thread.changeset(thread_attrs)
    |> put_assoc(:posts, [post_changeset])
  end
end
