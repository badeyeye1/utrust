defmodule UtrustWeb.SchemaTest do
  use UtrustWeb.ConnCase

  import Tesla.Mock

  @tx_mutation """
  mutation($txHash: String!, $scrape: Boolean) {
    verifyTransaction(txHash: $txHash, scrape: $scrape) {
      tx_hash
      status
      block
      from
      to
      valueEther
      feeEther
    }
  }
  """
  describe "can verify transactions using API or scraping" do
    test "returns `Transaction` when scrape is selected", %{conn: conn} do
      conn =
        post(conn, "/api", %{
          "query" => @tx_mutation,
          "variables" => %{
            txHash: "0x15f8e5ea1079d9a0bb04a4c58ae5fe7654b5b2b4463375ff7ffb490aa0032f3a",
            scrape: true
          }
        })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "verifyTransaction" => %{
                   "block" => "2166348",
                   "status" => "failed",
                   "tx_hash" =>
                     "0x15f8e5ea1079d9a0bb04a4c58ae5fe7654b5b2b4463375ff7ffb490aa0032f3a",
                   "feeEther" => "0.00315 Ether",
                   "from" => "0x58eb28a67731c570ef827c365c89b5751f9e6b0a",
                   "to" => "0xbf4ed7b27f1d666546e30d74d50d173d20bca754",
                   "valueEther" => "0 Ether"
                 }
               }
             }
    end

    test "returns  when scrape is selected", %{conn: conn} do
      mock_request(%{
        status: "1",
        message: "OK",
        result: %{
          isError: "0",
          errDescription: ""
        }
      })

      conn =
        post(conn, "/api", %{
          "query" => @tx_mutation,
          "variables" => %{
            txHash: "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"
          }
        })

      assert json_response(conn, 200) == %{
               "data" => %{
                 "verifyTransaction" => %{
                   "block" => nil,
                   "status" => "success",
                   "tx_hash" =>
                     "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0",
                   "feeEther" => nil,
                   "from" => nil,
                   "to" => nil,
                   "valueEther" => nil
                 }
               }
             }
    end

    defp mock_request(result) do
      mock(fn
        %{method: :get, url: "https://api.etherscan.io/api"} ->
          json(result)
      end)
    end
  end
end
