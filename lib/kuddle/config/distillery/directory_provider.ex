defmodule Kuddle.Config.Distillery.DirectoryProvider do
  @moduledoc """
  Use Kuddle as a config provider for a directory, if you want to load a single file see
  Kuddle.Config.Provider instead

  ## Example

      release :default do
        set config_providers: [
          {Kuddle.Config.Provider, [
            paths: [
              {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
            ],
            extensions: [".kdl", ".kuddle"]
          ]}
        ]
      end

  """
  @spec init(Kuddle.Config.DirectoryProvider.options()) :: :ok
  def init(opts) do
    state = Kuddle.Config.DirectoryProvider.init(opts)

    config = Kuddle.Config.DirectoryProvider.load([], state)

    Kuddle.Config.Utils.apply_configuration(config)
  end
end
