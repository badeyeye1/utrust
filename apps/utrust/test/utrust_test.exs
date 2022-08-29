defmodule UtrustTest do
  use ExUnit.Case

  import Tesla.Mock

  describe "verify_transaction/1" do
    test "should return :ok tuple when valid tx_hash is provided" do
      mock_request(%{
        status: "1",
        message: "OK",
        result: %{
          isError: "0",
          errDescription: ""
        }
      })

      assert {:ok, :transaction_successful} = Utrust.verify_transaction("tx_hash")
    end

    test "returns error tuple when tx_hash does not exists" do
      mock_request(%{
        status: "1",
        message: "OK",
        result: %{
          isError: "1",
          errDescription: "Bad jump destination"
        }
      })

      assert {:error, "Bad jump destination"} = Utrust.verify_transaction("tx_hash")
    end

    test "should retrun error tuple when arg is not a string" do
      assert {:error, :invalid_argument} = Utrust.verify_transaction(1)
      assert {:error, :invalid_argument} = Utrust.verify_transaction([])
      assert {:error, :invalid_argument} = Utrust.verify_transaction(["Hello"])
      assert {:error, :invalid_argument} = Utrust.verify_transaction(%{})
    end
  end

  defp mock_request(result) do
    mock(fn
      %{method: :get, url: "https://api.etherscan.io/api"} ->
        json(result)
    end)
  end
end
