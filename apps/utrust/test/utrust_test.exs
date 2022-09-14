defmodule UtrustTest do
  use ExUnit.Case

  import Tesla.Mock
  alias Utrust.Transaction

  @scrape_url "https://etherscan.io/tx/"
  @api_base_url "https://api.etherscan.io/api"

  describe "verify_transaction/2" do
    test "should return {:ok, Transaction} when transaction was successful" do
      tx_hash = "tx_hash"

      mock_request(%{
        status: "1",
        message: "OK",
        result: %{
          isError: "0",
          errDescription: ""
        }
      })

      assert {:ok, %Transaction{tx_hash: ^tx_hash, status: "success"}} =
               Utrust.verify_transaction(tx_hash, false)
    end

    test "should return {:ok, Transaction} when transaction failed" do
      tx_hash = "tx_hash"
      error_text = "Bad jump destination"

      mock_request(%{
        status: "1",
        message: "OK",
        result: %{
          isError: "1",
          errDescription: error_text
        }
      })

      assert {:ok, %Transaction{tx_hash: ^tx_hash, status: "failed", reason: ^error_text}} =
               Utrust.verify_transaction(tx_hash, false)
    end

    test "should return error tuple when status code is not 200" do
      tx_hash = "utrust"

      mock(fn
        %{method: :get, url: @api_base_url} ->
          {:ok, %Tesla.Env{status: 400}}
      end)

      assert {:error, _} = Utrust.verify_transaction(tx_hash, false)
    end

    test "should return error tuple when any other error occurs" do
      tx_hash = "utrust"

      mock(fn
        %{method: :get, url: @api_base_url} ->
          {:error, :nxdomain}
      end)

      assert {:error, _} = Utrust.verify_transaction(tx_hash, false)
    end

    # using scrapper
    test "Scrapper: should return {:ok, Transaction} when transaction was successful" do
      tx_hash = "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"

      result = Utrust.TransactionFixtures.successful_tx_fixture()

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert {:ok, %Transaction{status: "success", tx_hash: ^tx_hash}} =
               Utrust.verify_transaction(tx_hash, true)
    end

    test "Scrapper: should return {:ok, Transaction} when transaction failed" do
      tx_hash = "0x15f8e5ea1079d9a0bb04a4c58ae5fe7654b5b2b4463375ff7ffb490aa0032f3a"

      result = Utrust.TransactionFixtures.failed_tx_fixture()

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert {:ok, %Transaction{status: "failed", tx_hash: ^tx_hash}} =
               Utrust.verify_transaction(tx_hash, true)
    end

    test "Scrapper: should return {:error, :not_found} when transaction is not found" do
      tx_hash = "not_found"

      result = Utrust.TransactionFixtures.not_found_tx_fixture()

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 200, body: result}}
      end)

      assert {:error, :not_found} = Utrust.verify_transaction(tx_hash, true)
    end

    test "Scrapper: should return error tuple when status code is not 200" do
      tx_hash = "bad_hash"

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:ok, %Tesla.Env{status: 404, body: ""}}
      end)

      assert {:error, _} = Utrust.verify_transaction(tx_hash, true)
    end

    test "Scrapper: should return error tuple when any other error occurs" do
      tx_hash = "utrust"

      mock(fn
        %{method: :get, url: @scrape_url <> ^tx_hash} ->
          {:error, :nxdomain}
      end)

      assert {:error, _} = Utrust.verify_transaction(tx_hash, true)
    end
  end

  defp mock_request(result) do
    mock(fn
      %{method: :get, url: @api_base_url} ->
        json(result)
    end)
  end
end
