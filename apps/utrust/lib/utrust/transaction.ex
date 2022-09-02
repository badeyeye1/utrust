defmodule Utrust.Transaction do
  @type t() :: %__MODULE__{
          tx_hash: String.t(),
          status: String.t(),
          block: String.t(),
          block_confirmations: String.t(),
          timestamp: String.t(),
          from: String.t(),
          to: String.t(),
          value_ether: String.t(),
          value_usd: String.t(),
          fee_ether: String.t(),
          fee_usd: String.t()
        }

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
    :fee_usd
  ]
end
