defmodule Ether do
  @moduledoc """
  Documentation for `Ether`.
  """

  defdelegate verify_transaction(tx_hash), to: Ether.ApiClient, as: :verify_transaction

  defdelegate scrape_transaction(tx_hash), to: Ether.Scrapper, as: :verify_transaction
end
