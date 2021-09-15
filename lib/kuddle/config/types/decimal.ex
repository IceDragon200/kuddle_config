defmodule Kuddle.Config.Types.Decimal do
  def cast(%Decimal{} = value) do
    {:ok, value}
  end

  def cast(value) when is_binary(value) do
    case Decimal.parse(value) do
      {:ok, %Decimal{} = value} ->
        {:ok, value}

      {%Decimal{} = value, ""} ->
        {:ok, value}

      {%Decimal{}, _} ->
        :error

      :error ->
        :error
    end
  end

  def cast(value) when is_integer(value) do
    {:ok, Decimal.new(value)}
  end

  def cast(value) when is_float(value) do
    {:ok, Decimal.from_float(value)}
  end

  def cast(_) do
    :error
  end
end
