defmodule Ether.ApiClient do
  @moduledoc """
  This module provides a client for Etherscan API
  API docs available at https://docs.etherscan.io/api-endpoints/stats
  """
  @behaviour Ether.API

  use Tesla, only: [:get]
  require Logger

  alias Ether.Transaction

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
          {:ok, Transaction.t()} | {:error, :invalid_argument | String.t()}
  def verify_transaction(tx_hash) when is_binary(tx_hash) do
    payload = [module: "transaction", action: "getstatus", txhash: tx_hash, apiKey: get_api_key()]

    case get("/api", query: payload) do
      {:ok, %Tesla.Env{body: body, status: 200}} ->
        tx =
          body
          |> Jason.decode!()
          |> handle_response(tx_hash)

        {:ok, tx}

      {:ok, resp} ->
        {:error, resp}

      {:error, _} = response ->
        response
    end
  end

  def verify_transaction(_tx_hash), do: {:error, :invalid_argument}

  defp handle_response(%{"result" => %{"isError" => "0"}}, tx_hash) do
    Transaction.new(tx_hash: tx_hash, status: "success")
  end

  defp handle_response(%{"result" => %{"isError" => "1", "errDescription" => err}}, tx_hash) do
    Transaction.new(tx_hash: tx_hash, status: "failed", reason: err)
  end

  defp get_api_key do
    Application.get_env(:ether, :api_key)
  end
end
