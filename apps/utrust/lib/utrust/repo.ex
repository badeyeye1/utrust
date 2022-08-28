defmodule Utrust.Repo do
  use Ecto.Repo,
    otp_app: :utrust,
    adapter: Ecto.Adapters.Postgres
end
