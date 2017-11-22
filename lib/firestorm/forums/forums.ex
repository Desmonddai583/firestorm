defmodule Firestorm.Forums do
  @moduledoc """
  The Forums context.
  """

  import Ecto.Query, warn: false
  # alias Ecto.Multi
  alias Firestorm.Repo
  alias FirestormWeb.Notifications

  alias Firestorm.Forums.{User, Category, Thread, Post, Watch}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def login_or_register_from_identity(%{username: username, password: password}) do
    import Comeonin.Bcrypt, only: [checkpw: 2]

    case get_user_by_username(username) do
      nil ->
        # No user, let's register one!
        register_user(%{username: username, name: username, password: password})
      user ->
        # We'll check the password with checkpw against the user's stored
        # password hash
        case checkpw(password, user.password_hash) do
          true ->
            # Everything checks out, success
            {:ok, user}
          _ ->
            # User existed, we checked the password, but no dice
            {:error, "No user found with that username or password"}
        end
    end
  end

  alias Firestorm.Forums.Category

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  alias Firestorm.Forums.Thread

  @doc """
  Returns the list of threads for a given category. If provided a user, will determine whether each thread has been completely read or not.Returns the list of threads for a given category. If provided a user, will determine whether each thread has been completely read or not.
  ## Examples
      iex> list_threads(category)
      [%Thread{}, ...]
  """
  def list_threads(category, user \\ nil) do
    Thread
    |> where([t], t.category_id == ^category.id)
    |> preload(posts: :user)
    |> Repo.all
    |> Enum.map(fn(thread) ->
      first_post = Enum.at(thread.posts, 0)
      posts_count = length(thread.posts)
      completely_read? =
        if user do
          # TODO: Return true if the user has completely read this thread -
          # i.e., if each post has a corresponding view in the database for the
          # user
          false
        else
          false
        end
      %Thread{thread | first_post: first_post, posts_count: posts_count, completely_read?: completely_read?}
    end)
  end

  @doc """
  Gets a single user by email address. Maybe.
  """
  def get_user_by_email(email), do: Repo.get_by(User, %{email: email})
  # ...
  @doc """
  Gets a thread by id.

  Maybe returns a thread.
  """
  def get_thread(id) do
    Thread
    |> Repo.get(id)
  end

  @doc """
  Gets a single thread in a category.

  Raises `Ecto.NoResultsError` if the Thread does not exist in that category.

  ## Examples

      iex> get_thread!(category, 123)
      %Thread{}

      iex> get_thread!(category, 456)
      ** (Ecto.NoResultsError)

  """
  def get_thread!(category, id) do
    Thread
    |> where([t], t.category_id == ^category.id)
    |> Repo.get!(id)
  end

  @doc """
  Creates a thread.

  ## Examples

      iex> create_thread(category, user, %{field: value, body: "some body"})
      {:ok, {%Thread{}, %Post{}}}

      iex> create_thread(category, user, %{field: bad_value})
      {:error, :thread, %Ecto.Changeset{}}

  """
  def create_thread(category, user, attrs \\ %{}) do
    #####  Association way to create
    post_attrs =
      attrs
      |> Map.take([:body])
      |> Map.put(:user_id, user.id)

    thread_attrs =
      attrs
      |> Map.take([:title])
      |> Map.put(:category_id, category.id)

    %{thread: thread_attrs, post: post_attrs}
    |> Thread.new_thread_changeset
    |> Repo.insert
    #####  Multi Way to create
    # # We'll build as much of the post attributes we can for now - everything but
    # # the thread id
    # post_attrs =
    #   attrs
    #   |> Map.take([:body])
    #   |> Map.put(:user_id, user.id)

    # # We'll also build the thread attributes a bit more explicitly
    # thread_attrs =
    #   attrs
    #   |> Map.take([:title])
    #   |> Map.put(:category_id, category.id)

    # # We'll generate a thread changeset
    # thread_changeset =
    #   %Thread{}
    #   |> Thread.changeset(thread_attrs)

    # # And we'll start a new Ecto.Multi.
    # # This is a data structure that identifies the changes that we wish to make.
    # # We'll run it later in a `Repo.transaction`
    # multi =
    #   # We create a new Multi with Multi.new
    #   Multi.new
    #   # We'll insert our thread. The first argument here is the key by which we
    #   # can refer to this operation when we get the results or when we use
    #   # intermediate values mid-transaction in future `Multi` functions
    #   |> Multi.insert(:thread, thread_changeset)
    #   # Once we've inserted the thread, we'll use `Multi.run` so we can
    #   # reference the resulting thread to extract its id
    #   |> Multi.run(:post, fn %{thread: thread} ->
    #     # We'll add the thread_id to our post attributes
    #     post_attrs =
    #       post_attrs
    #       |> Map.put(:thread_id, thread.id)

    #     # We generate the post changeset and insert it
    #     post_changeset =
    #       %Post{}
    #       |> Post.changeset(post_attrs)
    #       |> Repo.insert
    #   end)

    # # Now we've described the transaction. All that remains is to actually run
    # # the transaction. This is accomplished by passing our Multi to
    # # Repo.transaction.
    # case Repo.transaction(multi) do
    #   # if it succeeds, we'll get an ok-tuple containing the result, which is a
    #   # map of our keys with the result of each operation. In this case, we'll
    #   # have a map with a `thread` and a `post` key.
    #   {:ok, result} ->
    #     # We'll return them in a 2-tuple, which is how I decided this return
    #     # should look.
    #     {:ok, {result.thread, result.post}}
    #   # In the event of an error, we get a 4-tuple containing :error, the key
    #   # that errored, the changeset for the error, and a map of the changes that
    #   # have occurred so far. We'll just return the thread changeset if there
    #   # was an error there.
    #   {:error, :thread, thread_changeset, _changes_so_far} ->
    #     {:error, :thread, thread_changeset}
    #   # Ditto for the post changeset if there's an error there.
    #   {:error, :post, post_changeset, _changes_so_far} ->
    #     {:error, :post, post_changeset}
    # end
  end

  @doc """
  Updates a thread.

  ## Examples

      iex> update_thread(thread, %{field: new_value})
      {:ok, %Thread{}}

      iex> update_thread(thread, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_thread(%Thread{} = thread, attrs) do
    thread
    |> Thread.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Thread.

  ## Examples

      iex> delete_thread(thread)
      {:ok, %Thread{}}

      iex> delete_thread(thread)
      {:error, %Ecto.Changeset{}}

  """
  def delete_thread(%Thread{} = thread) do
    Repo.delete(thread)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking thread changes.

  ## Examples

      iex> change_thread(thread)
      %Ecto.Changeset{source: %Thread{}}

  """
  def change_thread(%Thread{} = thread) do
    Thread.changeset(thread, %{})
  end

  def login_or_register_from_github(%{nickname: nickname, name: name, email: email}) do
    case get_user_by_username(nickname) do
      nil ->
        create_user(%{email: email, name: name, username: nickname})
      user ->
        {:ok, user}
    end
  end

  def get_user_by_username(username), do: Repo.get_by(User, %{username: username})

  alias Firestorm.Forums.Post

  def create_post(%Thread{} = thread, %User{} = user, attrs) do
    attrs =
      attrs
      |> Map.put(:thread_id, thread.id)
      |> Map.put(:user_id, user.id)

    with changeset <- Post.changeset(%Post{}, attrs),
         {:ok, post} <- Repo.insert(changeset),
         :ok <- Notifications.post_created(post) do
         {:ok, post}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.
  ## Examples
      iex> change_post(post)
      %Ecto.Changeset{source: %Post{}}
  """
  def change_post(%Post{} = post) do
    post
    |> Post.changeset(%{})
  end

  def user_posts(user, %{page: page}) do
    Post
    |> where([p], p.user_id == ^user.id)
    |> preload([p], [thread: [:category], user: []])
    |> Repo.paginate(page: page)
  end

  @doc """
  Have a user watch a thread:

      iex> %User{} |> watch(%Thread{})
      {:ok, %Watch{}}

  """
  def watch(%User{} = user, %Thread{} = thread) do
    thread
    |> Ecto.build_assoc(:watches, %{user_id: user.id})
    |> Watch.changeset(%{})
    |> Repo.insert()
  end

  @doc """
  Ensure a user no longer watches a thread:

      iex> %User{} |> unwatch(%Thread{})
      :ok

  """
  def unwatch(%User{} = user, %Thread{} = thread) do
    # Here we'll use a table name as a string, rather than a schema, as our
    # primary source query. You can do this if you want to interact with a
    # database without going through Schemas.
    "threads_watches"
    |> where(assoc_id: ^thread.id)
    |> where(user_id: ^user.id)
    |> Repo.delete_all()

    :ok
  end

  @doc """
  Determine if a user is watching a given watchable (Thread, etc):

      iex> %Thread{} |> watched_by?(%User{})
      false

  """
  def watched_by?(watchable, user = %User{}) do
    watch_count(watchable, user) > 0
  end

  def watcher_ids(watchable) do
    watchable
    |> watches()
    |> select([f], f.user_id)
    |> Repo.all
  end

  def watch_count(watchable) do
    watchable
    |> watches()
    |> Repo.aggregate(:count, :id)
  end
  defp watch_count(watchable, user = %User{}) do
    watchable
    |> watches()
    |> where([f], f.user_id == ^user.id)
    |> Repo.aggregate(:count, :id)
  end

  defp watches(watchable) do
    watchable
    |> Ecto.assoc(:watches)
  end
end
