defmodule Kuddle.Config.DirectoryProvider do
  @moduledoc """
  Use Kuddle as a config provider for a directory, if you want to load a single file see
  Kuddle.Config.Provider instead

  ## Example

      defp releases do
        [
          application: [
            config_providers: [
              {Kuddle.Config.Provider, [
                paths: [
                  {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
                ],
                extensions: [".kdl", ".kuddle"]
              ]}
            ]
          ]
        ]
      end

  """
  import Kuddle.Config.Utils

  @behaviour Config.Provider

  @typedoc """
  The directory provider allows specifying multiple paths to get config files from, this path
  will be joined with the wildcard **/* and postfixed with the extensions.

  Example:

      [
        paths: [
          "/etc/my_application/config"
        ]
      ]

  """
  @type paths_option :: {:paths, [Config.Provider.config_path()]}

  @typedoc """
  Specify a list of extensions that should be treated as kdl files.

  Default: [".kdl"]

  Example:

      [
        extensions: [".kdl", ".kuddle"]
      ]

  """
  @type extensions_option :: {:extensions, [String.t()]}

  @type option :: paths_option()
                | extensions_option()

  @typedoc """
  Options supported by the DirectoryProvider

  Example:

      [
        paths: [
          "/etc/my_application/config"
        ],
        extensions: [".cfg.kdl", ".cfg.kuddle"]
      ]

  """
  @type options :: [option()]

  @impl true
  @spec init(options()) :: any()
  def init(opts) do
    config =
      Enum.reduce(opts, %{paths: [], extensions: [".kdl"]}, fn
        {:paths, paths}, acc ->
          %{acc | paths: paths}

        {:extensions, exts}, acc ->
          %{acc | extensions: exts}
      end)

    config
  end

  @impl true
  def load(config, state) do
    Enum.reduce(state.paths, config, fn root_path, config ->
      case resolve_root_path(root_path) do
        nil ->
          raise Kuddle.ConfigError, message: "unresolved path", reason: {:error, :unresolved_path}

        path ->
          case File.stat(path) do
            {:ok, %{type: :regular}} ->
              raise Kuddle.ConfigError, message: "path is regular file", reason: {:error, :eisfile}

            {:ok, %{type: :directory}} ->
              Kuddle.Config.load_config_directory(path, state.extensions, config)

            {:error, reason} ->
              raise Kuddle.ConfigError, message: "path is inaccessible", reason: {:error, reason}
          end
      end
    end)
  end
end
