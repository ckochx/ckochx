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

    Process.sleep(:infinity)
  end
end
