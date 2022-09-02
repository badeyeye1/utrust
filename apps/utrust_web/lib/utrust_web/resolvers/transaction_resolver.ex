defmodule UtrustWeb.Resolvers.TransactionResolver do
  def verify_transaction(_root, %{tx_hash: tx_hash, scrape: true}, _info) do
    case Utrust.scrape_transaction(tx_hash) do
      {:ok, _} ->
        {:ok, %{tx_hash: tx_hash, status: :success}}

      response ->
        response
    end
  end

  def verify_transaction(_root, %{tx_hash: tx_hash}, _info) do
    case Utrust.verify_transaction(tx_hash) do
      {:ok, _} ->
        {:ok, %{tx_hash: tx_hash, status: :success}}

      response ->
        response
    end
  end
end
