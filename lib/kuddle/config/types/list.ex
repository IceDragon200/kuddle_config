defmodule Kuddle.Config.Types.List do
  def cast(value) when is_list(value) do
    {:ok, value}
  end
end
