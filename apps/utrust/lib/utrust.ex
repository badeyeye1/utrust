defmodule Utrust do
  @moduledoc """
  Utrust keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Ether.Transaction, as: EtherTransaction
  alias Utrust.Transaction

  @spec verify_transaction(String.t(), boolean()) ::
          {:ok, Transaction.t()} | {:error, term()}
  def verify_transaction(tx_hash, true) do
    tx_hash
    |> Ether.scrape_transaction()
    |> parse_response()
  end

  def verify_transaction(tx_hash, _) do
    tx_hash
    |> Ether.verify_transaction()
    |> parse_response()
  end

  defp parse_response({:ok, %EtherTransaction{} = tx}) do
    tx = tx |> Map.from_struct() |> Transaction.new()
    {:ok, tx}
  end

  defp parse_response(respone), do: respone
end
