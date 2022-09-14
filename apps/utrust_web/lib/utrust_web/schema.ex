defmodule UtrustWeb.Schema do
  @moduledoc false

  use Absinthe.Schema
  alias UtrustWeb.Resolvers.TransactionResolver

  query do
    field(:transactions, list_of(:transaction))
  end

  input_object :verify_transaction_input do
    field(:tx_hash, non_null(:string))
    field(:scrape, :boolean, default_value: false)
  end

  mutation do
    @desc "Verify transaction"
    field :verify_transaction, :transaction do
      arg(:input, non_null(:verify_transaction_input))

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
    field(:reason, :string)
  end
end
