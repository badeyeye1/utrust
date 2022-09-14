defmodule UtrustWeb.SchemaTest do
  use UtrustWeb.ConnCase

  import Tesla.Mock


  @query """
  mutation verifyTransaction($verifyTransaction: VerifyTransactionInput!) {
    verifyTransaction(input: $verifyTransaction) {
      txHash
      status
      from
      to
      block
      blockConfirmations
      valueEther
      valueUsd
      feeEther
      feeUsd
    }
  }
  """

  test "should verify transaction via API when scrape is false or not set", %{conn: conn} do
    tx_hash = "valid_tx_hash"

    result = %{
      status: "1",
      message: "OK",
      result: %{
        isError: "0",
        errDescription: ""
      }
    }

    mock(fn
      %{method: :get, url: "https://api.etherscan.io/api"} ->
        json(result)
    end)

    conn =
      post(conn, "/api", %{
        "query" => @query,
        "variables" => %{verifyTransaction: %{txHash: tx_hash}}
      })

    assert %{
             "data" => %{
               "verifyTransaction" => %{
                 "block" => nil,
                 "blockConfirmations" => nil,
                 "feeEther" => nil,
                 "feeUsd" => nil,
                 "from" => nil,
                 "status" => "success",
                 "to" => nil,
                 "txHash" => ^tx_hash,
                 "valueEther" => nil,
                 "valueUsd" => nil
               }
             }
           } = json_response(conn, 200)
  end

  test "should return error when scrape is false or not set", %{conn: conn} do
    tx_hash = "invalid_tx_hash"

    mock(fn
      %{method: :get, url: "https://api.etherscan.io/api"} ->
        {:ok, %Tesla.Env{status: 400}}
    end)

    conn =
      post(conn, "/api", %{
        "query" => @query,
        "variables" => %{verifyTransaction: %{txHash: tx_hash}}
      })

    assert json_response(conn, 200) == %{
             "data" => %{"verifyTransaction" => nil},
             "errors" => [
               %{
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "message" => "Something went wrong. Could not verify transaction",
                 "path" => ["verifyTransaction"]
               }
             ]
           }
  end

  test "should verify transaction via Scrapper when scrape is set to true", %{conn: conn} do
    tx_hash = "0x7b6d0e8d812873260291c3f8a9fa99a61721a033a01e5c5af3ceb5e1dc9e7bd0"

    result = Utrust.TransactionFixtures.successful_tx_fixture()

    mock_scrapper(tx_hash, 200, result)

    conn =
      post(conn, "/api", %{
        "query" => @query,
        "variables" => %{verifyTransaction: %{txHash: tx_hash, scrape: true}}
      })

    assert %{
             "data" => %{
               "verifyTransaction" => %{
                 "block" => "4954885",
                 "blockConfirmations" => "10567155",
                 "feeEther" => "0.00042 Ether",
                 "feeUsd" => "$0.72",
                 "from" => "0x0fe426d8f95510f4f0bac19be5e1252c4127ee00",
                 "status" => "success",
                 "to" => "0x4848535892c8008b912d99aaf88772745a11c809",
                 "txHash" => ^tx_hash,
                 "valueEther" => "0.371237 Ether",
                 "valueUsd" => "$635.91"
               }
             }
           } = json_response(conn, 200)
  end

  test "should return Not found via Scrapper when transaction is not found", %{conn: conn} do
    tx_hash = "random"

    result = Utrust.TransactionFixtures.not_found_tx_fixture()

    mock_scrapper(tx_hash, 200, result)

    conn =
      post(conn, "/api", %{
        "query" => @query,
        "variables" => %{verifyTransaction: %{txHash: tx_hash, scrape: true}}
      })

    assert %{
             "data" => %{
               "verifyTransaction" => nil
             },
             "errors" => [
               %{
                 "locations" => _,
                 "message" => "Transaction Not found",
                 "path" => ["verifyTransaction"]
               }
             ]
           } = json_response(conn, 200)
  end

  test "should return `Something went wrong` via Scrapper when request fails", %{conn: conn} do
    tx_hash = "random"

    mock_scrapper(tx_hash, 400)

    conn =
      post(conn, "/api", %{
        "query" => @query,
        "variables" => %{verifyTransaction: %{txHash: tx_hash, scrape: true}}
      })

    assert %{
             "data" => %{
               "verifyTransaction" => nil
             },
             "errors" => [
               %{
                 "locations" => _,
                 "message" => "Something went wrong. Could not verify transaction",
                 "path" => ["verifyTransaction"]
               }
             ]
           } = json_response(conn, 200)
  end

  defp mock_scrapper(tx_hash, status, result \\ nil) do
    mock(fn
      %{method: :get, url: "https://etherscan.io/tx/" <> ^tx_hash} ->
        {:ok, %Tesla.Env{status: status, body: result}}
    end)
  end
end
