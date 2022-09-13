defmodule SavitrBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      SavitrBackend.Repo,
      # Start the Telemetry supervisor
      SavitrBackendWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: SavitrBackend.PubSub},
      # Start the Endpoint (http/https)
      SavitrBackendWeb.Endpoint,
      SavitrBackendWeb.Presence
      # Start a worker by calling: SavitrBackend.Worker.start_link(arg)
      # {SavitrBackend.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SavitrBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SavitrBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
