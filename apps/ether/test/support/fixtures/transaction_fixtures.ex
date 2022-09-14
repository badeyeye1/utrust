defmodule Ether.TransactionFixtures do
   @moduledoc false

  @root_dir File.cwd!()
  @fixtures_dir Path.join(~w(#{@root_dir} test support fixtures))

  def successful_tx_fixture() do
    File.read!(@fixtures_dir <> "/successful_tx_response.html")
  end

  def failed_tx_fixture() do
    File.read!(@fixtures_dir <> "/failed_tx_response.html")
  end

  def not_found_tx_fixture() do
    File.read!(@fixtures_dir <> "/tx_not_found.html")
  end
end
