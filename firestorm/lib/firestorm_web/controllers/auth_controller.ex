defmodule FirestormWeb.AuthController do
  use FirestormWeb, :controller
  alias Firestorm.Forums
  alias Ueberauth.Strategy.Helpers
  alias Firestorm.Forums.User

  def request(conn, %{"provider" => "identity"}) do
    # We'll create a registration changeset and use Ueberauth helpers to provide
    # a callback url for our form to submit to
    changeset = User.registration_changeset(%User{}, %{})
    render(conn, "request.html", callback_url: Helpers.callback_url(conn), changeset: changeset)
  end

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

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    case auth.provider do
      :github ->
        with %{name: name, nickname: nickname, email: email} <- auth.info do
          case Forums.login_or_register_from_github(%{name: name, nickname: nickname, email: email}) do
            {:ok, user} ->
              conn
              |> ok_login(user)

            {:error, reason} ->
              conn
              |> put_flash(:error, reason)
              |> redirect(to: "/")
          end
        end
      :identity ->
        case Forums.login_or_register_from_identity(%{username: params["user"]["username"], password: params["user"]["password"]}) do
          {:ok, user} ->
            conn
            |> ok_login(user)

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "Login unsuccessful")
            |> render("request.html", callback_url: Helpers.callback_url(conn), changeset: changeset)

          {:error, reason} ->
            changeset = User.registration_changeset(%User{}, %{})

            conn
            |> put_flash(:error, reason)
            |> render("request.html", callback_url: Helpers.callback_url(conn), changeset: changeset)
        end
    end
  end

  defp ok_login(conn, user) do
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:current_user, user.id)
    |> redirect(to: "/")
  end
end