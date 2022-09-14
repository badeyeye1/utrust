defmodule EtherTest do
  use ExUnit.Case

  import Tesla.Mock
  alias Ether.Transaction
  alias Ether.TransactionFixtures

  @scrape_url "https://etherscan.io/tx/"
  @api_base_url "https://api.etherscan.io/api"

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

      assert {:ok, %Transaction{}} = Ether.verify_transaction("tx_hash")
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

      assert {:ok, %Transaction{reason: "Bad jump destination"}} =
               Ether.verify_transaction("tx_hash")
    end

    test "should retrun error tuple when arg is not a string" do
      assert {:error, :invalid_argument} = Ether.verify_transaction(1)
      assert {:error, :invalid_argument} = Ether.verify_transaction([])
      assert {:error, :invalid_argument} = Ether.verify_transaction(["Hello"])
      assert {:error, :invalid_argument} = Ether.verify_transaction(%{})
    end
  end

  defp mock_request(result) do
    mock(fn
      %{method: :get, url: @api_base_url} ->
        json(result)
    end)
  end

  describe "scrape_transaction/1" do
    test "should return successful `Transaction{}` when successful transaction hash is provided" do
      tx_hash = "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"

      result = TransactionFixtures.successful_tx_fixture()

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert {:ok, %Transaction{status: "success", tx_hash: ^tx_hash}} =
               Ether.scrape_transaction(tx_hash)
    end

    test "should return failed `Transaction{}` when failed transaction hash is provided" do
      tx_hash = "0x15f8e5ea1079d9a0bb04a4c58ae5fe7654b5b2b4463375ff7ffb490aa0032f3a"

      result = TransactionFixtures.failed_tx_fixture()

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert {:ok, %Transaction{status: "failed", tx_hash: ^tx_hash}} =
               Ether.scrape_transaction(tx_hash)
    end

    test "should return `nil` when transaction hash is not found" do
      tx_hash = "bad_hash"

      result = TransactionFixtures.not_found_tx_fixture()

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert {:error, :not_found} = Ether.scrape_transaction(tx_hash)
    end

    test "should return error tuple when Scraper returns status code in [40x, 50x]" do
      tx_hash = "bad_hash"

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 404, body: ""}}
      end)

      assert {:error, _} = Ether.scrape_transaction(tx_hash)
    end
  end
end
