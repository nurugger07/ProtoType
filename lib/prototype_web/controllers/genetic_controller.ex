defmodule PrototypeWeb.GeneticController do
  use PrototypeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
