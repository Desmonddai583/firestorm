defmodule FirestormWeb.Plugs.CurrentUser do
  @moduledoc """
  A `Plug` to assign `:current_user` based on the session
  """

  import Plug.Conn
  import Firestorm.Session, only: [current_user: 1]

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> assign(:current_user, current_user(conn))
  end
end