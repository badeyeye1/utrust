defmodule Utrust.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:payment_transactions, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:tx_hash, :string, null: false)
      add(:status, :string)
      add(:value_ether, :decimal)
      add(:value_usd, :decimal)
      add(:block, :integer)
      add(:block_confirmations, :integer)
      add(:fee_ether, :decimal)
      add(:fee_usd, :decimal)
      add(:sender_address, :string)
      add(:recipient_address, :string)
      add(:tx_timestamp, :string)

      timestamps()
    end

    create(unique_index(:payment_transactions, [:tx_hash]))
  end
end
