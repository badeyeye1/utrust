defmodule UtrustWeb.Resolvers.TransactionResolver do
  @moduledoc false

  alias Utrust.Transaction

  def verify_transaction(_root, %{input: %{tx_hash: tx_hash, scrape: scrape}}, _info) do
    case Utrust.verify_transaction(tx_hash, scrape) do
      {:ok, %Transaction{}} = result ->
        result

      {:error, :not_found} ->
        {:error, "Transaction Not found"}

      {:error, _} ->
        {:error, "Something went wrong. Could not verify transaction"}
    end
  end
end
