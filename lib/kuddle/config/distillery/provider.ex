defmodule Kuddle.Config.Distillery.Provider do
  @moduledoc """
  Use Kuddle as a config provider for a single file, if you want to load a directory see
  Kuddle.Config.Distillery.DirectoryProvider instead.

  This is a variant of the Config.Provider specifically used for Distillery

  ## Example

      release :default do
        set config_providers: [
          {Kuddle.Config.Provider, [
            path: {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
          ]}
        ]
      end

  """
  @spec init(Kuddle.Config.Provider.options()) :: :ok
  def init(opts) do
    state = Kuddle.Config.Provider.init(opts)

    config = Kuddle.Config.Provider.load([], state)

    Kuddle.Config.Utils.apply_configuration(config)
  end
end
