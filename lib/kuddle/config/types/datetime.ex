defmodule Kuddle.Config.Types.DateTime do
  def cast(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, %DateTime{} = value, _} ->
        {:ok, value}

      {:error, _} ->
        :error
    end
  end
end
