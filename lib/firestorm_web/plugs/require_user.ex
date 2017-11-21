defmodule FirestormWeb.Plugs.RequireUser do
  @moduledoc """
  A `Plug` to redirect to the root path if there is no current user
  """

  import Plug.Conn
  # We need to be able to modify the flash and redirect the user in the event of
  # no user.
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  # We want to use route helpers
  import FirestormWeb.Router.Helpers
  # We'll bring in the logged_in? function to check if the user is logged in
  import Firestorm.Session, only: [logged_in?: 1]

  def init(options), do: options

  def call(conn, _opts) do
    if logged_in?(conn) do
      # if the user's logged in then we don't modify the connection
      conn
    else
      # otherwise, we notify them that they must log in and redirect to the root
      # path.
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: category_path(conn, :index))
      # We have to halt the connection so that it knows to send it to the user
      # and stop performing our plug chain here.
      |> halt()
    end
  end
end