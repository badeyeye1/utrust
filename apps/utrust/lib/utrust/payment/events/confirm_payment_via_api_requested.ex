defmodule Utrust.Payment.Events.ConfirmPaymentViaApiRequested do
  @derive Jason.Encoder

  defstruct [:tx_hash]
end
