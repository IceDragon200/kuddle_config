defmodule Kuddle.Config do
  @moduledoc """
  Utility module for handling various sources of configuration using Kuddle.
  """
  alias Kuddle.Node
  alias Kuddle.Value

  import Kuddle.Config.Utils, only: [mod_to_atom: 1]

  @doc """
  Load a config map from a given kdl blob.

  Usage:

      {:ok, config} = Kuddle.Config.load_config_blob(\"\"\"
      my_application {
        key "value"
        key2 subkey="subvalue"
      }
      \"\"\")

  """
  @spec load_config_blob(String.t(), Keyword.t()) :: {:ok, Keyword.t()} | {:error, term()}
  def load_config_blob(blob, config \\ []) do
    with {:ok, document, []} <- Kuddle.decode(blob),
         {:ok, config2} <- load_config_document(document) do
      {:ok, Config.Reader.merge(config, config2)}
    end
  end

  @doc """
  Load a KDL config file

  Usage:

      {:ok, config} = Kuddle.Config.load_config_file("/path/to/kdl/config/file")

  """
  @spec load_config_file(Path.t(), Keyword.t()) :: {:ok, Keyword.t()} | {:error, term()}
  def load_config_file(filename, config \\ []) do
    with {:ok, blob} <- File.read(filename) do
      load_config_blob(blob, config)
    end
  end

  @doc """
  Load config from a directory, the extensions of the config files must be supplied as well.

  Usage:

      {:ok, config} =
        Kuddle.Config.load_config_directory("/path/to/kdl/config/directory", [".kdl", ".kuddle"])

  """
  def load_config_directory(directory_path, extensions, config \\ []) do
    Enum.reduce(extensions, config, fn extname, config ->
      wildcard_path = Path.join([directory_path, "**/*#{extname}"])

      Enum.reduce(Path.wildcard(wildcard_path), config, fn filename, config ->
        case load_config_file(filename, config) do
          {:ok, config2} ->
            Config.Reader.merge(config, config2)

          {:error, reason} ->
            raise Kuddle.ConfigError, message: "config failed to load", reason: reason
        end
      end)
    end)
  end

  @doc """
  Load config from a given kuddle document.

  Usage:

    {:ok, config} =
      Kuddle.Config.load_config_document(document)

  """
  @spec load_config_document(Kuddle.document(), Keyword.t()) ::
          {:ok, Keyword.t()} | {:error, term()}
  def load_config_document(document, acc \\ [])

  def load_config_document([node | rest], acc) do
    case config_from_node(node) do
      {:ok, pair} ->
        load_config_document(rest, [pair | acc])

      {:error, _} = err ->
        err
    end
  end

  def load_config_document([], acc) do
    {:ok, Enum.reverse(acc)}
  end

  defp config_from_value(%Value{annotations: [], value: value}) do
    {:ok, value}
  end

  defp config_from_value(%Value{annotations: [type], value: value}) do
    Kuddle.Config.Types.cast(type, value)
  end

  defp config_from_attributes(attributes, acc \\ [])

  defp config_from_attributes([], acc) do
    {:ok, Enum.reverse(acc)}
  end

  defp config_from_attributes([{%Value{} = key, %Value{} = value} = pair | rest], acc) do
    case config_from_value(value) do
      {:ok, value} ->
        config_from_attributes(rest, [{kuddle_value_to_atom(key), value} | acc])

      :error ->
        {:error, {:attribute_error, pair}}
    end
  end

  defp config_from_attributes([%Value{} = value | rest], acc) do
    case config_from_value(value) do
      {:ok, value} ->
        config_from_attributes(rest, [value | acc])

      :error ->
        {:error, {:attribute_error, value}}
    end
  end

  defp config_from_node(%Node{name: name, attributes: attributes, annotations: annotations, children: nil}) do
    case config_from_attributes(attributes) do
      {:ok, config} ->
        case annotations do
          [type] ->
            case Kuddle.Config.Types.cast(type, config) do
              {:ok, value} ->
                {:ok, {mod_to_atom(name), value}}

              {:error, _} = err ->
                err
            end

          [] ->
            {:ok, {mod_to_atom(name), maybe_single(config)}}
        end

      {:error, _} = err ->
        err
    end
  end

  defp config_from_node(%Node{name: name, attributes: attributes, children: children}) do
    with {:ok, config} <- config_from_attributes(attributes),
         {:ok, config2} <- load_config_document(children) do
      config = Config.Reader.merge(config, config2)
      {:ok, {mod_to_atom(name), config}}
    end
  end

  defp maybe_single([a]) do
    a
  end

  defp maybe_single(a) do
    a
  end

  defp kuddle_value_to_atom(%Value{value: key}) do
    mod_to_atom(key)
  end
end
