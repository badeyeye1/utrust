defmodule Utrust.Payment.Events.PaymentConfirmed do
  @derive Jason.Encoder

  defstruct [
    :tx_hash,
    :status,
    :block,
    :block_confirmations,
    :timestamp,
    :from,
    :to,
    :value_ether,
    :value_usd,
    :fee_ether,
    :fee_usd,
    :reason
  ]

  use ExConstructor
end
