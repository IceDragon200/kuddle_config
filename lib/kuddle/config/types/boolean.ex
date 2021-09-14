defmodule Kuddle.Config.Types.Boolean do
  def cast(value) when is_boolean(value) do
    {:ok, value}
  end

  def cast(value) when is_binary(value) do
    value = String.upcase(value)

    cond do
      value in ["YES", "Y", "1", "T", "TRUE"] ->
        {:ok, true}

      value in ["NO", "N", "0", "F", "FALSE"] ->
        {:ok, false}

      true ->
        :error
    end
  end

  def cast(0) do
    {:ok, false}
  end

  def cast(n) when n > 0 do
    {:ok, true}
  end

  def cast(_) do
    :error
  end
end
