defmodule Utrust.Payment.Events.ConfirmPaymentViaScrapperRequested do
  @derive Jason.Encoder

  defstruct [:tx_hash]
end
