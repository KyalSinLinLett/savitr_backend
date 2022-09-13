defmodule SavitrBackendWeb.PageController do
  use SavitrBackendWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
