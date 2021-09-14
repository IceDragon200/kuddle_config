defmodule Kuddle.Config.DirectoryProviderTest do
  use ExUnit.Case, async: true

  describe "load/2" do
    test "can load all config files in a directory" do
      state = Kuddle.Config.DirectoryProvider.init([
        paths: [Path.expand("../../fixtures/config/", __DIR__)],
        extensions: [".kdl", ".kuddle"],
      ])

      config = Kuddle.Config.DirectoryProvider.load([], state)

      assert [
        application_a: [
          subkey1: [
            a: "1",
            b: "2",
            c: "3"
          ],
          subkey2: [
            a: 1,
            b: 2,
            c: [3]
          ],
          subkey3: [
            a: [
              key: "1",
              value: "x"
            ],
            b: [
              key: "2",
              value: "y"
            ],
            c: [
              key: "3",
              value: "z"
            ]
          ]
        ],
        application_b: [
          a: "1",
          b: "2",
          c: [
            value: "3"
          ]
        ]
      ] = Enum.sort(config)
    end
  end
end
