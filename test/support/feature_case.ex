defmodule FirestormWeb.FeatureCase do
  use ExUnit.CaseTemplate

  defmodule Helpers do
    use Wallaby.DSL

    # Move this from the ThreadsTest, make it public
    def log_in_as(session, user) do
      session
      |> visit("/")
      |> Browser.set_cookie("current_user", user.id)
    end
  end

  using do
    quote do
      use Wallaby.DSL

      alias FirestormWeb.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import FirestormWeb.FeatureCase.Helpers
      import FirestormWeb.Router.Helpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Firestorm.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Firestorm.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Firestorm.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end