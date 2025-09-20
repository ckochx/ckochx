defmodule Mix.Tasks.Dev do
  @moduledoc """
  Start the Ckochx development server with hot reloading.

  ## Usage

      mix dev

  This will:
  - Start the web server on port 4000
  - Enable hot code reloading for .ex, .exs, .md, .html files
  - Watch lib/ and priv/ directories for changes
  - Automatically recompile when files change
  """

  use Mix.Task
  require Logger

  @shortdoc "Start development server with hot reloading"
  @requirements ["app.config"]

  def run(_args) do
    Logger.info("""
    🚀 Starting Ckochx development server...

    📍 Server: http://localhost:4000
    📁 Routes:
       GET /         - Blog index
       GET /about    - About page
       GET /blog     - Blog index
       GET /blog/:slug - Blog posts

    🔥 Hot reloading enabled - edit files and see changes instantly!

    Press Ctrl+C twice to stop
    """)

    # Ensure all dependencies are compiled
    Mix.Task.run("compile")

    # Start the application
    {:ok, _pid} = Application.ensure_all_started(:ckochx)

    # Start file watcher
    start_file_watcher()

    # Keep the process alive
    Process.sleep(:infinity)
  end

  defp start_file_watcher do
    paths_to_watch = ["lib", "priv"]

    {:ok, watcher_pid} = FileSystem.start_link(dirs: paths_to_watch)
    FileSystem.subscribe(watcher_pid)

    spawn(fn -> file_watcher_loop() end)

    Logger.info("📁 Watching #{Enum.join(paths_to_watch, ", ")} for changes...")
  end

  defp file_watcher_loop do
    receive do
      {:file_event, _watcher_pid, {path, events}} ->
        if should_reload?(path, events) do
          Logger.info("🔄 File changed: #{path} - reloading...")
          reload_application()
        end

        file_watcher_loop()

      {:file_event, _watcher_pid, :stop} ->
        Logger.info("📁 File watcher stopped")

      _ ->
        file_watcher_loop()
    end
  end

  defp should_reload?(path, events) do
    # Only reload for actual changes, not temporary files
    valid_extension = Path.extname(path) in [".ex", ".exs", ".md", ".html"]
    has_changes = :modified in events or :created in events

    not_temp_file =
      not String.contains?(path, "~") and not String.starts_with?(Path.basename(path), ".")

    valid_extension and has_changes and not_temp_file
  end

  defp reload_application do
    try do
      # Recompile
      case Mix.Task.rerun("compile") do
        :ok ->
          # For development, we'll purge and reload all modules
          # This is simpler than trying to restart supervisor children
          :code.purge(Ckochx.WebServer)
          :code.load_file(Ckochx.WebServer)
          :code.purge(Ckochx.Blog)
          :code.load_file(Ckochx.Blog)

          Logger.info("✅ Application reloaded successfully")

        {:error, _} ->
          Logger.error("❌ Compilation failed - not reloading")
      end
    rescue
      e ->
        Logger.error("❌ Reload failed: #{inspect(e)}")
    end
  end
end
