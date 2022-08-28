defmodule UtrustWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      UtrustWeb.Telemetry,
      # Start the Endpoint (http/https)
      UtrustWeb.Endpoint
      # Start a worker by calling: UtrustWeb.Worker.start_link(arg)
      # {UtrustWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UtrustWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UtrustWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
