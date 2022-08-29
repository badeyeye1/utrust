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
end
