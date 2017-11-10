defmodule FirestormWeb.AuthController do
  use FirestormWeb, :controller
  alias Firestorm.Forums

  # Users can log out - we just drop their session
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  # If we get a failure callback, we'll just inform the user of the failure with
  # no additional details.
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  # If we authorized successfully, we'll handle each provider differently.
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case auth.provider do
      # Of course we only have the one for now
      :github ->
        # We'll extract the name, nickname, and email from the auth info
        with %{name: name, nickname: nickname, email: email} <- auth.info do
          # Then we'll call a function that will either return an existing user
          # with this github email address or create and return a new user
          case Forums.login_or_register_from_github(%{name: name, nickname: nickname, email: email}) do
            {:ok, user} ->
              # If it succeeds, we'll put the current user id in the session and
              # redirect home.
              conn
              |> put_flash(:info, "Successfully authenticated.")
              |> put_session(:current_user, user.id)
              |> redirect(to: "/")

            # Otherwise, we'll show the issue to the user
            {:error, reason} ->
              conn
              |> put_flash(:error, reason)
              |> redirect(to: "/")
          end
        end
    end
  end
end