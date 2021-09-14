defmodule Kuddle.Config.Types.Decimal do
  def cast(value) do
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
end
