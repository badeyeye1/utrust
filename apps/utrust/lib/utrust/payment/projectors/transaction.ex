defmodule Utrust.Payment.Projectors.Transaction do
  use Commanded.Projections.Ecto,
    application: Utrust.App,
    name: "Payment.Projectors.Transaction"

  alias Utrust.Payment.Events.PaymentConfirmed
  alias Utrust.Payment.Projections.Transaction

  require Logger

  project(%PaymentConfirmed{} = transaction, _meta, fn multi ->
    %PaymentConfirmed{
      tx_hash: tx_hash,
      status: status,
      from: from,
      to: to,
      value_ether: value_ether,
      value_usd: value_usd,
      fee_ether: fee_ether,
      fee_usd: fee_usd,
      block: block,
      block_confirmations: block_confirmations,
      timestamp: timestamp
    } = transaction

    Ecto.Multi.insert(multi, :payment_transaction, %Transaction{
      uuid: Ecto.UUID.generate(),
      tx_hash: tx_hash,
      status: status,
      block: String.to_integer(block),
      block_confirmations: String.to_integer(block_confirmations),
      sender_address: from,
      recipient_address: to,
      value_ether: ether(value_ether),
      value_usd: usd(value_usd),
      fee_ether: ether(fee_ether),
      fee_usd: usd(fee_usd),
      tx_timestamp: timestamp
    })
  end)

  defp ether(data) do
    String.split(data) |> hd() |> to_float()
  end

  defp to_float(data) do
    if String.contains?(data, ".") do
      String.to_float(data)
    else
      (data <> ".0") |> String.to_float()
    end
  end

  defp usd(""), do: 0.0

  defp usd(data) do
    String.replace(data, "$", "") |> to_float()
  end

  def error({:error, error}, event, failure_context) do
    Logger.error("""
    An error occured - #{inspect(error)}
    \n for event #{inspect(event)}
    \n In context of #{inspect(failure_context)}
    """)

    :skip
  end
end
