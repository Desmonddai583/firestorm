defmodule Firestorm.Forums.Notification do
  @moduledoc """
  Schema for notifications.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{User, Notification}

  schema "notifications" do
    field :body, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Notification{} = notification, attrs) do
    notification
    |> cast(attrs, [:user_id, :body])
    |> validate_required([:user_id, :body])
  end
end