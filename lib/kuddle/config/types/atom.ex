defmodule Kuddle.Config.Types.Atom do
  def cast(value) do
    {:ok, String.to_atom(value)}
  end
end
