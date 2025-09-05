defmodule Dev.Reloader do
  @moduledoc """
  Development file watcher and code reloader for Ckochx.
  Automatically recompiles and restarts the server when files change.
  """

  use GenServer
  require Logger

  @watched_dirs ["lib", "priv"]
  @watched_extensions [".ex", ".exs", ".md", ".html", ".css", ".js"]

  def start_link(_opts) do
    if Mix.env() == :dev do
      GenServer.start_link(__MODULE__, [], name: __MODULE__)
    else
      :ignore
    end
  end

  @impl true
  def init([]) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: @watched_dirs)
    FileSystem.subscribe(watcher_pid)

    Logger.info("🔥 Hot reloading enabled - watching #{inspect(@watched_dirs)}")

    {:ok, %{watcher_pid: watcher_pid, last_reload: System.monotonic_time(:millisecond)}}
  end

  @impl true
  def handle_info({:file_event, watcher_pid, {path, events}}, %{watcher_pid: watcher_pid} = state) do
    if should_reload?(path, events, state.last_reload) do
      reload_code()
      {:noreply, %{state | last_reload: System.monotonic_time(:millisecond)}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:file_event, _watcher_pid, _event}, state) do
    {:noreply, state}
  end

  defp should_reload?(path, events, last_reload) do
    # Only reload for relevant file changes
    relevant_extension? = Enum.any?(@watched_extensions, &String.ends_with?(path, &1))
    relevant_event? = Enum.any?(events, &(&1 in [:modified, :created]))
    # Debounce
    not_too_recent? = System.monotonic_time(:millisecond) - last_reload > 500

    relevant_extension? and relevant_event? and not_too_recent?
  end

  defp reload_code do
    Logger.info("🔄 File changed - recompiling and reloading...")

    # Recompile changed modules
    case IEx.Helpers.recompile() do
      :ok ->
        Logger.info("✅ Code reloaded successfully")
        clear_blog_cache()

      :noop ->
        Logger.debug("📝 No changes detected")

      {:error, _} ->
        Logger.warning("⚠️  Compilation errors - please check your code")
    end
  end

  defp clear_blog_cache do
    # If we implement blog caching later, clear it here
    # For now, blog posts are read from disk each time
    :ok
  end
end
