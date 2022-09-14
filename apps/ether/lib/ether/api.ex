defmodule Ether.API do
   @moduledoc false

  alias Ether.Transaction

  @callback verify_transaction(String.t()) :: {:ok, Transaction.t()} | {:error, term()}
end
