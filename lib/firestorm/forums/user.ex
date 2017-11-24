defmodule Firestorm.Forums.User do
  @moduledoc """
  Schema for forum users.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  alias Firestorm.Forums.{User, Post}

  schema "users" do
    field :email, :string
    field :name, :string
    field :username, :string
    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :posts, Post

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :name])
    |> validate_required([:username, :name])
    |> unique_constraint(:username)
  end

  def registration_changeset(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_length(:password, min: 6)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        changeset
        |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  def avatar_url(%__MODULE__{email: email, username: username}, size \\ 256) do
    if email do
      gravatar_url(email, username, size)
    else
      adorable_url(username, size)
    end
  end

  defp gravatar_url(email, username, size) do
    email
    |> Exgravatar.gravatar_url(d: adorable_url(username, size), s: size)
  end

  defp adorable_url(username, size) do
    "https://api.adorable.io/avatars/#{size}/#{username}@adorable.png"
  end
end
