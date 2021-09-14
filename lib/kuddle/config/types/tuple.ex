defmodule Kuddle.Config.Types.Tuple do
  def cast(value) when is_list(value) do
    {:ok, List.to_tuple(value)}
  end
end
