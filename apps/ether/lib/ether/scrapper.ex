defmodule Ether.Scrapper do
  @moduledoc """
  This module Scrapes transaction data as seen on https://etherscan.ix/tx
  """
  @behaviour Ether.API
  require Logger

  alias Ether.Transaction

  @impl true
  @spec verify_transaction(String.t()) :: {:ok, Transaction.t()} | {:error, term()}
  def verify_transaction(tx_hash) do
    case Tesla.get("https://etherscan.io/tx/" <> tx_hash, headers: [{"user-agent", "Mozilla/5.0"}]) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        {:ok, html} = Floki.parse_document(body)

        html
        |> Floki.find("#ContentPlaceHolder1_maintable")
        |> Floki.find(".row")
        |> build_tx()
        |> case do
          nil ->
            {:error, :not_found}

          tx ->
            {:ok, tx}
        end

      {:ok, response} ->
        Logger.error(
          "Failed to scrape transaction. \nGot the following response from server: #{inspect(response)}"
        )

        {:error, :sometheg_went_wrong}

      {:error, _resp} = error ->
        error
    end
  end

  def rows(html) do
    Floki.find(html, ".row")
  end

  def build_tx(rows) do
    total_rows = length(rows)

    cond do
      total_rows == 14 ->
        successful_tx(rows)

      total_rows == 13 ->
        failed_tx(rows)

      true ->
        nil
    end
  end

  defp successful_tx(rows) do
    struct(Transaction,
      tx_hash: rows |> hd() |> get_hash(),
      status: rows |> Enum.at(1) |> get_status(),
      block: rows |> Enum.at(2) |> get_block(),
      block_confirmations: rows |> Enum.at(2) |> get_confirmations(),
      timestamp: rows |> Enum.at(3) |> get_timestamp(),
      from: rows |> Enum.at(4) |> get_wallet_address(),
      to: rows |> Enum.at(5) |> get_wallet_address(),
      value_ether: rows |> Enum.at(6) |> get_value_ether(),
      value_usd: rows |> Enum.at(6) |> get_value_usd(),
      fee_ether: rows |> Enum.at(7) |> get_transaction_fee(),
      fee_usd: rows |> Enum.at(7) |> get_value_usd()
    )
  end

  defp failed_tx(rows) do
    struct(Transaction,
      tx_hash: rows |> hd() |> get_hash(),
      status: "failed",
      block: rows |> Enum.at(1) |> get_block(),
      block_confirmations: rows |> Enum.at(1) |> get_confirmations(),
      timestamp: rows |> Enum.at(2) |> get_timestamp(),
      from: rows |> Enum.at(3) |> get_wallet_address(),
      to: rows |> Enum.at(4) |> get_wallet_address(),
      value_ether: rows |> Enum.at(5) |> get_value_ether(),
      value_usd: rows |> Enum.at(5) |> get_value_usd(),
      fee_ether: rows |> Enum.at(6) |> get_transaction_fee(),
      fee_usd: rows |> Enum.at(6) |> get_value_usd()
    )
  end

  defp get_hash(html) do
    html |> Floki.find("#spanTxHash") |> Floki.text()
  end

  defp get_status(html) do
    html |> Floki.text() |> String.split(":") |> Enum.at(-1) |> String.downcase()
  end

  defp get_block(html) do
    html |> Floki.find("a") |> Floki.text()
  end

  defp get_confirmations(html) do
    html
    |> Floki.find("span.u-label")
    |> Floki.text()
    |> String.split(" ")
    |> hd()
  end

  defp get_timestamp(html) do
    html |> Floki.find("div.col-md-9") |> Floki.text() |> String.replace("\n", "")
  end

  defp get_wallet_address(html) do
    html |> Floki.find("a") |> Floki.text()
  end

  defp get_value_ether(html) do
    html |> Floki.find("span.u-label") |> Floki.text()
  end

  defp get_value_usd(html) do
    html
    |> Floki.find("button.u-label")
    |> Floki.text()
    |> String.trim()
    |> String.replace("(", "")
    |> String.replace(")", "")
  end

  defp get_transaction_fee(html) do
    html |> Floki.find("span#ContentPlaceHolder1_spanTxFee > span") |> Floki.text()
  end
end
