defmodule Kuddle.Config do
  alias Kuddle.Node
  alias Kuddle.Value

  def config_from_value(%Value{annotations: [], value: value}) do
    {:ok, value}
  end

  def config_from_value(%Value{annotations: [type], value: value}) do
    Kuddle.Config.Types.cast(type, value)
  end

  def config_from_attributes(attributes, acc \\ [])

  def config_from_attributes([], acc) do
    {:ok, Enum.reverse(acc)}
  end

  def config_from_attributes([{%Value{value: key}, %Value{} = value} = pair | rest], acc) do
    case config_from_value(value) do
      {:ok, value} ->
        config_from_attributes(rest, [{String.to_atom(key), value} | acc])

      :error ->
        {:error, {:attribute_error, pair}}
    end
  end

  def config_from_attributes([%Value{} = value | rest], acc) do
    case config_from_value(value) do
      {:ok, value} ->
        config_from_attributes(rest, [value | acc])

      :error ->
        {:error, {:attribute_error, value}}
    end
  end

  def config_from_node(%Node{name: name, attributes: attributes, annotations: annotations, children: nil}) do
    case config_from_attributes(attributes) do
      {:ok, config} ->
        case annotations do
          [type] ->
            case Kuddle.Config.Types.cast(type, config) do
              {:ok, value} ->
                {:ok, {String.to_atom(name), value}}

              {:error, _} = err ->
                err
            end

          [] ->
            {:ok, {String.to_atom(name), maybe_single(config)}}
        end

      {:error, _} = err ->
        err
    end
  end

  def config_from_node(%Node{name: name, attributes: attributes, children: children}) do
    with {:ok, config} <- config_from_attributes(attributes),
         {:ok, config2} <- config_from_document(children) do
      config = Config.Reader.merge(config, config2)
      {:ok, {String.to_atom(name), config}}
    end
  end

  def config_from_document(document, acc \\ [])

  def config_from_document([node | rest], acc) do
    case config_from_node(node) do
      {:ok, pair} ->
        config_from_document(rest, [pair | acc])

      {:error, _} = err ->
        err
    end
  end

  def config_from_document([], acc) do
    {:ok, Enum.reverse(acc)}
  end

  def load_config_blob(blob, config \\ []) do
    with {:ok, document, []} <- Kuddle.decode(blob),
         {:ok, config2} <- config_from_document(document) do
      {:ok, Config.Reader.merge(config, config2)}
    end
  end

  def load_config_file(filename, config \\ []) do
    with {:ok, blob} <- File.read(filename) do
      load_config_blob(blob, config)
    end
  end

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

  defp maybe_single([a]) do
    a
  end

  defp maybe_single(a) do
    a
  end
end
