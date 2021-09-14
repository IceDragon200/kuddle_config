defmodule Kuddle.Config.Utils do
  @spec resolve_root_path(Config.Provider.config_path() | nil) :: Path.t() | nil
  def resolve_root_path(nil) do
    nil
  end

  def resolve_root_path(path) do
    Config.Provider.resolve_config_path!(path)
  end
end
