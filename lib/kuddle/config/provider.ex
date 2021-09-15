defmodule Kuddle.Config.Provider do
  @moduledoc """
  Use Kuddle as a config provider for a single file, if you want to load a directory see
  Kuddle.Config.DirectoryProvider instead

  ## Example

      defp releases do
        [
          application: [
            config_providers: [
              {Kuddle.Config.Provider, [
                path: {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
              ]}
            ]
          ]
        ]
      end

  """
  import Kuddle.Config.Utils

  @behaviour Config.Provider

  @typedoc """
  The path to the KDL config file that should be loaded.
  """
  @type path_option :: {:path, Config.Provider.config_path()}

  @type option :: path_option()

  @type options :: [option()]

  @impl true
  @spec init(options()) :: any()
  def init(opts) do
    state =
      Enum.reduce(opts, %{path: nil}, fn
        {:path, path}, acc ->
          %{acc | path: path}
      end)

    state
  end

  @impl true
  def load(config, state) do
    case resolve_root_path(state.path) do
      nil ->
        raise Kuddle.ConfigError, message: "unresolved path", reason: {:error, :unresolved_path}

      path ->
        case File.stat(path) do
          {:ok, %{type: :regular}} ->
            case Kuddle.Config.load_config_file(path, config) do
              {:ok, config} ->
                config

              {:error, reason} ->
                raise Kuddle.ConfigError, message: "config failed to load", reason: reason
            end

          {:ok, %{type: :directory}} ->
            raise Kuddle.ConfigError, message: "path is directory", reason: {:error, :eisdir}

          {:error, reason} ->
            raise Kuddle.ConfigError, message: "path is inaccessible", reason: {:error, reason}
        end
    end
  end
end
