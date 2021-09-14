defmodule Kuddle.Config.Types do
  @default_types [
    date: {Date, :from_iso8601},
    utc_datetime: {DateTime, :from_iso8601},
    naive_datetime: {NaiveDateTime, :from_iso8601},
    time: {Time, :from_iso8601},
    decimal: {Kuddle.Config.Types.Decimal, :cast},
    atom: {Kuddle.Config.Types.Atom, :cast},
    boolean: {Kuddle.Config.Types.Boolean, :cast},
    tuple: {Kuddle.Config.Types.Tuple, :cast},
    list: {Kuddle.Config.Types.List, :cast},
  ]

  default_types = Application.get_env(:kuddle_config, :default_types, @default_types)

  user_types = Application.get_env(:kuddle_config, :types, [])

  all_types = Keyword.merge(default_types, user_types)

  @spec cast(atom() | String.t(), any()) :: {:ok, any()} | :error
  def cast(type, value) do
    case internal_cast(type, value) do
      {:ok, value} ->
        {:ok, value}

      {:error, _reason} ->
        :error

      :error ->
        :error
    end
  end

  @spec internal_cast(atom() | String.t(), any()) :: {:ok, any()} | {:error, term} | :error
  def internal_cast(type, value)

  for {type, {module, func_name}} <- all_types do
    str = Atom.to_string(type)

    def internal_cast(unquote(str), value) do
      internal_cast(unquote(type), value)
    end

    def internal_cast(unquote(type), value) do
      unquote(module).unquote(func_name)(value)
    end
  end

  def internal_cast(_type, _) do
    :error
  end
end
