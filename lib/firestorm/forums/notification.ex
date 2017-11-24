defmodule Firestorm.Forums.Notification do
  @moduledoc """
  Schema for notifications.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import FirestormWeb.Router.Helpers
  alias Firestorm.Forums.{User, Thread, Post, Notification}
  alias FirestormWeb.Endpoint

  schema "notifications" do
    field :body, :string
    field :subject, :string
    field :url, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :body, :subject, :url])
    |> validate_required([:user_id, :body, :subject, :url])
  end

  def thread_new_post_notification(%Thread{} = thread, %Post{} = post) do
    %{
      subject: "There was a new post in thread: #{thread.title}",
      body: post.body,
      url: post_url(thread, post)
    }
  end

  defp post_url(thread, post) do
    "#{thread_url(thread)}#post-#{post.id}"
  end

  defp thread_url(thread) do
    category_thread_url(Endpoint, :show, thread.category_id, thread.id)
  end
end