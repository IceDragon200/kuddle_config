defmodule Kuddle.Config.Utils do
  @spec apply_configuration(Keyword.t()) :: :ok
  def apply_configuration(config) do
    for {app_name, app_config} <- config do
      base = Application.get_all_env(app_name)

      merged = deep_merge(base, app_config)

      # Persist key/value pairs for this app
      for {k, v} <- merged do
        Application.put_env(app_name, k, v, persistent: true)
      end
    end
    :ok
  end

  # snatched from Toml.Provider
  def deep_merge(a, b) when is_list(a) and is_list(b) do
    if Keyword.keyword?(a) and Keyword.keyword?(b) do
      Keyword.merge(a, b, &deep_merge/3)
    else
      b
    end
  end

  def deep_merge(_k, a, b) when is_list(a) and is_list(b) do
    if Keyword.keyword?(a) and Keyword.keyword?(b) do
      Keyword.merge(a, b, &deep_merge/3)
    else
      b
    end
  end

  def deep_merge(_k, a, b) when is_map(a) and is_map(b) do
    Map.merge(a, b, &deep_merge/3)
  end

  def deep_merge(_k, _a, b), do: b

  @spec resolve_root_path(Config.Provider.config_path() | nil) :: Path.t() | nil
  def resolve_root_path(nil) do
    nil
  end

  def resolve_root_path({:system, name}) do
    System.fetch_env!(name)
  end

  def resolve_root_path({:system, name, default_path}) do
    System.get_env(name, default_path)
  end
end
