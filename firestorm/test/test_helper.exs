ExUnit.configure(exclude: [pending: true])
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Firestorm.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, FirestormWeb.Endpoint.url)
Application.put_env(:firestorm, :get_session_from_cookies, true)