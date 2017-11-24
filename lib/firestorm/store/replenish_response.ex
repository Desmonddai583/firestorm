defmodule Firestorm.Store.ReplenishResponse do
  defstruct categories: [], threads: [], users: [], posts: []
  alias Firestorm.Forum.{Category, Thread, User, Post}

  @type t :: %Firestorm.Store.ReplenishResponse{
    categories: list(Category.t),
    threads: list(Thread.t),
    users: list(User.t),
    posts: list(Post.t),
  }
end