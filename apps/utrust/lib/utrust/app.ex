defmodule Utrust.App do
  @moduledoc false

  use Commanded.Application,
    otp_app: :utrust,
    event_store: [
      adapter: Commanded.EventStore.Adapters.EventStore,
      event_store: Utrust.EventStore
    ]

  router(Utrust.Router)
end
