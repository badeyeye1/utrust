defmodule Utrust.Router do
  use Commanded.Commands.Router
  alias Utrust.Payment.Aggregates.Payment
  alias Utrust.Payment.Commands.ConfirmPayment

  dispatch(ConfirmPayment, to: Payment, identity: :tx_hash)
end
