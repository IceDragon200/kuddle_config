defmodule Kuddle.Config.ProviderTest do
  use ExUnit.Case, async: true

  describe "load/2" do
    test "can load a single config file" do
      state = Kuddle.Config.Provider.init([
        path: Path.expand("../../fixtures/config/a.kdl", __DIR__)
      ])

      config = Kuddle.Config.Provider.load([], state)

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
        ]
      ] = config
    end

    test "can handle module names in config" do
      state = Kuddle.Config.Provider.init([
        path: Path.expand("../../fixtures/config/modules.kdl", __DIR__)
      ])

      config = Kuddle.Config.Provider.load([], state)

      assert [
        modules: [
          {Module.A, [
            key: 1
          ]},
          {Module.B, [
            value: 2
          ]},
        ]
      ] = config
    end
  end
end
