defmodule Utrust.TransactionFixtures do
  @moduledoc false

  defdelegate successful_tx_fixture, to: Ether.TransactionFixtures, as: :successful_tx_fixture
  defdelegate failed_tx_fixture, to: Ether.TransactionFixtures, as: :failed_tx_fixture
  defdelegate not_found_tx_fixture, to: Ether.TransactionFixtures, as: :not_found_tx_fixture
end
