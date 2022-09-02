defmodule Utrust do
  @moduledoc """
  Utrust keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Tesla, only: [:get]

  plug(Tesla.Middleware.BaseUrl, "https://api.etherscan.io")

  plug(Tesla.Middleware.Retry,
    delay: 200,
    max_retries: 3,
    max_delay: 4_000,
    should_retry: fn
      {:ok, %{status: status}} when status in [400, 500] -> true
      {:ok, _} -> false
      {:error, _} -> true
    end
  )

  @spec verify_transaction(String.t()) ::
          {:ok, :transaction_successful} | {:error, :invalid_argument | String.t()}
  def verify_transaction(tx_hash) when is_binary(tx_hash) do
    payload = [module: "transaction", action: "getstatus", txhash: tx_hash, apiKey: get_api_key()]

    case get("/api", query: payload) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        body
        |> Jason.decode!()
        |> handle_response()

      {:ok, resp} ->
        {:error, resp}
    end
  end

  def verify_transaction(_tx_hash), do: {:error, :invalid_argument}

  defp handle_response(%{"result" => %{"isError" => "0"}}), do: {:ok, :transaction_successful}

  defp handle_response(%{"result" => %{"isError" => "1", "errDescription" => err}}),
    do: {:error, err}

  defp get_api_key do
    Application.get_env(:utrust, :api_key)
  end

  def scrape_transaction(tx_hash) do
    response = HTTPotion.get("https://etherscan.io/tx/" <> tx_hash)

    {:ok, html} = Floki.parse_document(response.body)

    html
    |> Floki.find("#ContentPlaceHolder1_maintable")
    |> Floki.find(".row")
    |> build_tx()
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
        %{}
    end
  end

  defp successful_tx(rows) do
    %{
      tx_hash: rows |> hd() |> get_hash(),
      status: rows |> Enum.at(1) |> get_status(),
      block: rows |> Enum.at(2) |> get_block(),
      block_confirmations: rows |> Enum.at(2) |> get_confirmations(),
      timestamp: rows |> Enum.at(3) |> get_timestamp(),
      from: rows |> Enum.at(4) |> get_wallet_address(),
      to: rows |> Enum.at(5) |> get_wallet_address(),
      value_ether: rows |> Enum.at(6) |> get_value_ether(),
      value_usd: rows |> Enum.at(6) |> get_value_usd(),
      transaction_fee: rows |> Enum.at(7) |> get_transaction_fee(),
      transaction_fee_usd: rows |> Enum.at(7) |> get_value_usd()
    }
  end

  defp failed_tx(rows) do
    %{
      tx_hash: rows |> hd() |> get_hash(),
      status: "Failed",
      block: rows |> Enum.at(1) |> get_block(),
      block_confirmations: rows |> Enum.at(1) |> get_confirmations(),
      timestamp: rows |> Enum.at(2) |> get_timestamp(),
      from: rows |> Enum.at(3) |> get_wallet_address(),
      to: rows |> Enum.at(4) |> get_wallet_address(),
      value_ether: rows |> Enum.at(5) |> get_value_ether(),
      value_usd: rows |> Enum.at(5) |> get_value_usd(),
      transaction_fee: rows |> Enum.at(6) |> get_transaction_fee(),
      transaction_fee_usd: rows |> Enum.at(6) |> get_value_usd()
    }
  end

  defp get_hash(html) do
    html |> Floki.find("#spanTxHash") |> Floki.text()
  end

  defp get_status(html) do
    html |> Floki.text() |> String.split(":") |> Enum.at(-1)
  end

  defp get_block(html) do
    html |> Floki.find("a") |> Floki.text() |> String.to_integer()
  end

  defp get_confirmations(html) do
    html
    |> Floki.find("span.u-label")
    |> Floki.text()
    |> String.split(" ")
    |> hd()
    |> String.to_integer()
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
