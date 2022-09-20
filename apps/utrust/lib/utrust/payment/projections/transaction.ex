defmodule Utrust.Payment.Projections.Transaction do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}
  schema "payment_transactions" do
    field(:tx_hash, :string)
    field(:status, :string)
    field(:value_ether, :decimal)
    field(:value_usd, :decimal)
    field(:block, :integer)
    field(:block_confirmations, :integer)
    field(:fee_ether, :decimal)
    field(:fee_usd, :decimal)
    field(:sender_address, :string)
    field(:recipient_address, :string)
    field(:tx_timestamp, :string)

    timestamps()
  end
end
