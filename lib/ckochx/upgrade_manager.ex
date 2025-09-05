defmodule Ckochx.UpgradeManager do
  @moduledoc """
  Manages hot code upgrades and release management for Ckochx.

  This module handles:
  - Version detection and management
  - Hot upgrade execution
  - Rollback capabilities
  - Health checks during upgrades
  """

  use GenServer
  require Logger

  # 30 seconds
  @upgrade_check_interval 30_000
  @upgrade_dir "/opt/ckochx/releases"

  def start_link(opts \\ []) do
    if Application.get_env(:ckochx, :enable_hot_upgrades, false) do
      GenServer.start_link(__MODULE__, opts, name: __MODULE__)
    else
      :ignore
    end
  end

  @doc "Get current application version"
  def current_version do
    case Application.spec(:ckochx, :vsn) do
      nil -> "unknown"
      vsn -> to_string(vsn)
    end
  end

  @doc "Check for available upgrades"
  def check_for_upgrades do
    if Process.whereis(__MODULE__) do
      GenServer.call(__MODULE__, :check_upgrades)
    else
      {:error, :upgrade_manager_not_running}
    end
  end

  @doc "Perform hot upgrade to specified version"
  def upgrade_to_version(version) do
    if Process.whereis(__MODULE__) do
      GenServer.call(__MODULE__, {:upgrade, version}, 60_000)
    else
      {:error, :upgrade_manager_not_running}
    end
  end

  @doc "Rollback to previous version"
  def rollback do
    if Process.whereis(__MODULE__) do
      GenServer.call(__MODULE__, :rollback, 60_000)
    else
      {:error, :upgrade_manager_not_running}
    end
  end

  @impl true
  def init(opts) do
    interval = opts[:check_interval] || @upgrade_check_interval

    # Schedule periodic upgrade checks
    if interval > 0 do
      Process.send_after(self(), :check_upgrades, interval)
    end

    Logger.info("🔄 Hot upgrade manager started - checking every #{interval}ms")

    {:ok,
     %{
       current_version: current_version(),
       check_interval: interval,
       last_check: System.monotonic_time(:millisecond)
     }}
  end

  @impl true
  def handle_info(:check_upgrades, state) do
    check_and_maybe_upgrade()

    # Schedule next check
    if state.check_interval > 0 do
      Process.send_after(self(), :check_upgrades, state.check_interval)
    end

    {:noreply, %{state | last_check: System.monotonic_time(:millisecond)}}
  end

  @impl true
  def handle_call(:check_upgrades, _from, state) do
    result = check_and_maybe_upgrade()
    {:reply, result, state}
  end

  def handle_call({:upgrade, version}, _from, state) do
    result = perform_upgrade(version)
    new_version = if match?({:ok, _}, result), do: version, else: state.current_version
    {:reply, result, %{state | current_version: new_version}}
  end

  def handle_call(:rollback, _from, state) do
    result = perform_rollback()
    {:reply, result, state}
  end

  # Private functions

  defp check_and_maybe_upgrade do
    case find_available_upgrades() do
      [] ->
        Logger.debug("No upgrades available")
        :no_upgrades

      [latest_version | _] = versions ->
        current = current_version()

        if version_newer?(latest_version, current) do
          Logger.info("🔄 Found newer version: #{latest_version} (current: #{current})")

          # Auto-upgrade if configured
          if Application.get_env(:ckochx, :auto_upgrade, false) do
            Logger.info("🚀 Auto-upgrading to version #{latest_version}")
            perform_upgrade(latest_version)
          else
            {:upgrade_available, latest_version, versions}
          end
        else
          :up_to_date
        end
    end
  end

  defp find_available_upgrades do
    if File.dir?(@upgrade_dir) do
      @upgrade_dir
      |> File.ls!()
      |> Enum.filter(&File.dir?(Path.join(@upgrade_dir, &1)))
      |> Enum.filter(&valid_version?/1)
      |> Enum.sort(&version_newer?(&1, &2))
    else
      []
    end
  rescue
    _ -> []
  end

  defp perform_upgrade(version) do
    current = current_version()
    upgrade_path = Path.join([@upgrade_dir, version])

    Logger.info("🔄 Starting hot upgrade from #{current} to #{version}")

    cond do
      not File.dir?(upgrade_path) ->
        {:error, :version_not_found}

      version == current ->
        {:error, :already_at_version}

      true ->
        case :release_handler.unpack_release(version) do
          {:ok, _} ->
            case :release_handler.install_release(version, []) do
              {:ok, _, _} ->
                case :release_handler.make_permanent(version) do
                  :ok ->
                    Logger.info("✅ Successfully upgraded to version #{version}")
                    {:ok, version}

                  {:error, reason} ->
                    Logger.error(
                      "❌ Failed to make version #{version} permanent: #{inspect(reason)}"
                    )

                    {:error, {:permanent_failed, reason}}
                end

              {:error, reason} ->
                Logger.error("❌ Failed to install version #{version}: #{inspect(reason)}")
                {:error, {:install_failed, reason}}
            end

          {:error, reason} ->
            Logger.error("❌ Failed to unpack version #{version}: #{inspect(reason)}")
            {:error, {:unpack_failed, reason}}
        end
    end
  rescue
    error ->
      Logger.error("❌ Exception during upgrade: #{inspect(error)}")
      {:error, {:exception, error}}
  end

  defp perform_rollback do
    Logger.info("🔄 Starting rollback to previous version")

    case :release_handler.which_releases() do
      releases when length(releases) >= 2 ->
        # Find the previous permanent release
        case Enum.find(releases, fn {_, _, _, status} -> status == :old end) do
          {previous_version, _, _, _} ->
            case :release_handler.reboot_old_release(to_charlist(previous_version)) do
              :ok ->
                Logger.info("✅ Successfully rolled back to version #{previous_version}")
                {:ok, previous_version}

              {:error, reason} ->
                Logger.error("❌ Failed to rollback: #{inspect(reason)}")
                {:error, reason}
            end

          nil ->
            {:error, :no_previous_version}
        end

      _ ->
        {:error, :no_previous_version}
    end
  rescue
    error ->
      Logger.error("❌ Exception during rollback: #{inspect(error)}")
      {:error, {:exception, error}}
  end

  defp valid_version?(version_string) do
    # Simple version validation (semantic versioning)
    String.match?(version_string, ~r/^\d+\.\d+\.\d+.*$/)
  end

  defp version_newer?(v1, v2) when is_binary(v1) and is_binary(v2) do
    case Version.compare(v1, v2) do
      :gt -> true
      _ -> false
    end
  rescue
    _ -> false
  end
end
