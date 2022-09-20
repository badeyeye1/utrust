defmodule Utrust.Payment.Aggregates.Payment do
  alias __MODULE__
  alias Utrust.Payment.Commands.ConfirmPayment
  alias Utrust.Payment.Events.ConfirmPaymentViaScrapperRequested
  # alias Utrust.Payment.Events.ConfirmPaymentViaApiRequested
  alias Utrust.Payment.Events.PaymentConfirmed

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

  def execute(%Payment{tx_hash: nil}, %ConfirmPayment{tx_hash: tx_hash, use_scrapper: scraper}) do
    case Utrust.verify_transaction(tx_hash, scraper) do
      {:ok, transaction} ->
        transaction |> Map.from_struct() |> PaymentConfirmed.new()

      _ ->
        []
    end
  end

  def apply(%Payment{} = payment, %PaymentConfirmed{} = event) do
    %Payment{
      payment
      | status: event.status,
        block: event.block,
        block_confirmations: event.block_confirmations,
        timestamp: event.timestamp,
        from: event.from,
        to: event.to,
        value_ether: event.value_ether,
        value_usd: event.value_usd,
        fee_ether: event.fee_ether,
        fee_usd: event.fee_usd,
        reason: event.reason
    }
  end

  def apply(%Payment{} = payment, %ConfirmPaymentViaScrapperRequested{tx_hash: tx_hash}) do
    %Payment{payment | tx_hash: tx_hash}
  end
end
