defmodule Kuddle.Config.Types do
  @moduledoc """
  Annotation cast types.

  User specific types can be registered by setting the kuddle_config types:

  ## Example

      config :kuddle_config,
        types: [
          typename: {Module, cast_function_name},

          geopoint: {MyGeoPoint, :cast},
        ]

  The cast function must return {:ok, any()} or :error if it cannot cast the given value.

  Kuddle Config has some default types they can be overwritten by setting the default_types:

      config :kuddle_config,
        default_types: [
          date: {Date, :from_iso8601},
          utc_datetime: {Kuddle.Config.Types.DateTime, :cast},
          naive_datetime: {NaiveDateTime, :from_iso8601},
          time: {Time, :from_iso8601},
          decimal: {Kuddle.Config.Types.Decimal, :cast},
          atom: {Kuddle.Config.Types.Atom, :cast},
          boolean: {Kuddle.Config.Types.Boolean, :cast},
          tuple: {Kuddle.Config.Types.Tuple, :cast},
          list: {Kuddle.Config.Types.List, :cast},
        ]

  The purpose of the default_types is to provide some sane default which doesn't require any
  additional configuration from you, the user.

  However they can be disabled by setting the default_types config.
  """
  @default_types [
    date: {Date, :from_iso8601},
    utc_datetime: {Kuddle.Config.Types.DateTime, :cast},
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

  @doc """
  Cast given value to a different type, normally the input will a string.
  """
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
