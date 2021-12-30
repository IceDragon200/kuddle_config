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

  @spec resolve_root_path!(Config.Provider.config_path() | nil) :: Path.t() | nil
  def resolve_root_path!(nil) do
    nil
  end

  def resolve_root_path!({:system, name}) do
    System.fetch_env!(name)
  end

  def resolve_root_path!({:system, name, default_path}) do
    System.get_env(name, default_path)
  end

  def resolve_root_path!(path) when is_binary(path) do
    path
  end

  # Graciously borrowed from TOML
  # Convert the given key (as binary) to an atom
  # Handle converting uppercase keys to module names rather than plain atoms
  def mod_to_atom(<<c::utf8, _::binary>> = key) when c >= ?A and c <= ?Z do
    Module.concat([key])
  end

  def mod_to_atom(key), do: String.to_atom(key)

  # Convert the given key (as binary) to an existing atom
  # Handle converting uppercase keys to module names rather than plain atoms
  #
  # NOTE: This throws an error if the atom does not exist, and is intended to
  # be handled in the decoder
  def mod_to_existing_atom(<<c::utf8, _::binary>> = key) when c >= ?A and c <= ?Z do
    Module.concat([String.to_existing_atom(key)])
  rescue
    _ ->
      throw({:error, {:keys, {:non_existing_atom, key}}})
  end

  def mod_to_existing_atom(key) do
    String.to_existing_atom(key)
  rescue
    _ ->
      throw({:error, {:keys, {:non_existing_atom, key}}})
  end
end
