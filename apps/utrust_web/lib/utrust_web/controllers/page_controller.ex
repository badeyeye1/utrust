defmodule UtrustWeb.PageController do
  use UtrustWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
