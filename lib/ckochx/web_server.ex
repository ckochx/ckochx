defmodule Ckochx.WebServer do
  use Plug.Router

  plug Plug.Logger
  plug Plug.Static, 
    at: "/", 
    from: "priv/static",
    only: ~w(css js images fonts favicon.ico robots.txt),
    gzip: false

  plug :match
  plug :dispatch

  get "/" do
    send_file(conn, 200, "priv/static/index.html")
  end

  match _ do
    send_resp(conn, 404, "Page not found")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts \\ []) do
    port = opts[:port] || 4000
    
    Bandit.start_link(
      plug: __MODULE__,
      port: port,
      scheme: :http
    )
  end
end