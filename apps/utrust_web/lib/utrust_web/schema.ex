defmodule UtrustWeb.Schema do
  use Absinthe.Schema
  alias UtrustWeb.Resolvers.TransactionResolver

  query do
    field(:transactions, list_of(:transaction))
  end

  mutation do
    @desc "Verify transaction"
    field :verify_transaction, :transaction do
      arg(:tx_hash, non_null(:string))
      arg(:scrape, :boolean)

      resolve(&TransactionResolver.verify_transaction/3)
    end
  end

  object :transaction do
    field(:tx_hash, :string)
    field(:status, :string)
    field(:to, :string)
    field(:from, :string)
    field(:block, :string)
    field(:block_confirmations, :string)
    field(:value_ether, :string)
    field(:value_usd, :string)
    field(:fee_ether, :string)
    field(:fee_usd, :string)
  end
end
