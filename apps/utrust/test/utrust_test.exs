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

  describe "scrape_transaction/1" do
    test "should return successful `Transaction{}` when successful transaction hash is provided" do
      tx_hash = "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"

      result = File.read!("test/support/fixtures/successful_tx_response.html")

      mock(fn
        %{method: :get, url: "https://etherscan.io/tx/" <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert %Utrust.Transaction{status: "success", tx_hash: ^tx_hash} = Utrust.scrape_transaction(tx_hash)
    end

    test "should return failed `Transaction{}` when failed transaction hash is provided" do
      tx_hash = "0x15f8e5ea1079d9a0bb04a4c58ae5fe7654b5b2b4463375ff7ffb490aa0032f3a"

      result = File.read!("test/support/fixtures/failed_tx_response.html")

      mock(fn
        %{method: :get, url: "https://etherscan.io/tx/" <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert %Utrust.Transaction{status: "failed", tx_hash: ^tx_hash} = Utrust.scrape_transaction(tx_hash)
    end

    test "should return `nil` when transaction hash is not found" do
      tx_hash = "bad_hash"

      result = File.read!("test/support/fixtures/tx_not_found.html")

      mock(fn
        %{method: :get, url: "https://etherscan.io/tx/" <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      refute  Utrust.scrape_transaction(tx_hash)
    end

    test "should return error tuple when Scraper returns status code in [40x, 50x]" do
      tx_hash = "bad_hash"

      mock(fn
        %{method: :get, url: "https://etherscan.io/tx/" <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 404, body: ""}}
      end)

      assert {:error, _} =  Utrust.scrape_transaction(tx_hash)
    end
  end
end
