defmodule Ckochx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:ckochx, :port, 4000)

    children =
      [
        {Ckochx.WebServer, [port: port]},
        Ckochx.UpgradeManager
      ] ++ dev_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Ckochx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp dev_children do
    if Mix.env() == :dev do
      [Dev.Reloader]
    else
      []
    end
  end
end
