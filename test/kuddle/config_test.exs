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
  end
end
