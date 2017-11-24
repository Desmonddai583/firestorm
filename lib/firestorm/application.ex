defmodule Firestorm.Application do
  @moduledoc false
  
  use Application
  import Supervisor.Spec

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Firestorm.Supervisor]
    Supervisor.start_link(children(Mix.env), opts)
  end

  defp default_children() do
    [
      # Start the Ecto repository
      supervisor(Firestorm.Repo, []),
      # Start the endpoint when the application starts
      supervisor(FirestormWeb.Endpoint, []),
      # Add an LRU Cache for storing OEmbed results for a given URL, storing at
      # most 5000 results at a time in the cache.
      worker(LruCache, [:oembed_cache, 5_000])
    ]
  end
  defp children(:test) do
    default_children()
  end

  defp children(_) do
    default_children() ++
    [
      # Start the notifications server
      worker(FirestormWeb.Notifications, []),
    ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    FirestormWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
