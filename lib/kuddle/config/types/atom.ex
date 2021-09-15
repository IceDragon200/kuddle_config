defmodule Kuddle.Config.Types.Atom do
  def cast(value) when is_atom(value) do
    {:ok, value}
  end

  def cast(value) when is_binary(value) do
    {:ok, String.to_atom(value)}
  end

  def cast(_) do
    :error
  end
end
