defmodule MeApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MeApp.Repo,
      {Cachex, name: :me_app},
      # Start the Telemetry supervisor
      MeAppWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MeApp.PubSub},
      # Start the Endpoint (http/https)
      MeAppWeb.Endpoint
      # Start a worker by calling: MeApp.Worker.start_link(arg)
      # {MeApp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MeApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MeAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
