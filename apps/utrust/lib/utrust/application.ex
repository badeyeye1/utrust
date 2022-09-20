defmodule Utrust.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Utrust.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Utrust.PubSub},
      Utrust.App,
      Utrust.Payment.Supervisor
      # Start a worker by calling: Utrust.Worker.start_link(arg)
      # {Utrust.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Utrust.Supervisor)
  end
end
