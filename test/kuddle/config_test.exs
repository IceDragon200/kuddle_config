defmodule Kuddle.ConfigTest do
  use ExUnit.Case, async: true

  describe "load_config_blob/1" do
    test "can load a kdl blob as config" do
      assert {:ok, config} =
        Kuddle.Config.load_config_blob("""
        kuddle_config {
          types {
            (tuple)date (atom)"Date" (atom)"from_iso8601"
            (tuple)datetime (atom)"DateTime" (atom)"from_iso8601"
          }
        }
        """)

      assert [
        kuddle_config: [
          types: [
            date: {:Date, :from_iso8601},
            datetime: {:DateTime, :from_iso8601},
          ]
        ]
      ] = config
    end

    test "all default type annotations" do
      assert {:ok, config} =
        Kuddle.Config.load_config_blob("""
        config {
          date (date)"2021-09-14"
          utc_datetime (utc_datetime)"2021-09-14T18:00:00.000000Z"
          naive_datetime (naive_datetime)"2021-09-14T18:00:00.000000"
          time (time)"18:00:00"
          decimal_s (decimal)"1.23E1000"
          decimal_i (decimal)10
          decimal_f (decimal)10.123
          atom (atom)"eggs"
          boolean_t (boolean)#true
          boolean_f (boolean)#false
          boolean_1 (boolean)1
          boolean_0 (boolean)0
          boolean_y (boolean)"YES"
          boolean_n (boolean)"NO"
          (tuple)tuple "abc" 123
          (list)list_one 1
          (list)list 1 2 3
        }
        """)

      assert [
        config: [
          date: ~D[2021-09-14],
          utc_datetime: ~U[2021-09-14T18:00:00.000000Z],
          naive_datetime: ~N[2021-09-14T18:00:00.000000],
          time: ~T[18:00:00],
          decimal_s: %Decimal{},
          decimal_i: %Decimal{},
          decimal_f: %Decimal{},
          atom: :eggs,
          boolean_t: true,
          boolean_f: false,
          boolean_1: true,
          boolean_0: false,
          boolean_y: true,
          boolean_n: false,
          tuple: {"abc", 123},
          list_one: [1],
          list: [1, 2, 3],
        ]
      ] = config
    end
  end
end
