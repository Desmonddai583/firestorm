defmodule Firestorm.Forums.Thread do
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{Thread, Category, Post, Watch, User}
  alias Firestorm.Forums.Slugs.ThreadTitleSlug

  schema "threads" do
    field :title, :string
    field :slug, ThreadTitleSlug.Type
    field :first_post, {:map, %Post{}}, virtual: true
    field :posts_count, :integer, virtual: true
    field :completely_read?, :boolean, virtual: true

    belongs_to :category, Category
    has_many :posts, Post
    # We're specifying the table to find associated watches through, rather than
    # just providing another schema.
    has_many :watches, {"threads_watches", Watch}, foreign_key: :assoc_id
    # We'll also use `many_to_many` to find all the users watching this thread
    # through the same association.
    many_to_many :watchers, User, join_through: "threads_watches", join_keys: [assoc_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%Thread{} = thread, attrs) do
    thread
    |> cast(attrs, [:title, :category_id])
    |> validate_required([:title, :category_id])
    |> ThreadTitleSlug.maybe_generate_slug
    |> ThreadTitleSlug.unique_constraint
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
