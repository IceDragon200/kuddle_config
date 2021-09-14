defmodule Kuddle.Config.Provider do
  @moduledoc """
  Use Kuddle as a config provider for a single file, if you want to load a directory see
  Kuddle.Config.DirectoryProvider instead
  """
  import Kuddle.Config.Utils

  @behaviour Config.Provider

  @impl true
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
