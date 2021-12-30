# Kuddle Config

An Elixir [`Config.Provider`](https://hexdocs.pm/elixir/master/Config.Provider.html) using [kuddle](https://github.com/IceDragon200/kuddle), also general configuration helpers using Kuddle.

## Installation

To add `kuddle_config` to your project:

```elixir
def deps do
  [
    {:kuddle_config, "~> 0.2.0"}
  ]
end
```

## Usage

Kuddle provides 2 different config providers:

### Single File Providers

The default Config.Provider which will load a kdl file as config

#### Kuddle.Config.Provider

Used for elixir releases:

```elixir
# Format
defp releases do
  [
    application: [
      config_providers: [
        {Kuddle.Config.Provider, [
          path: config_path()
        ]}
      ]
    ]
  ]
end

# Example
defp releases do
  [
    application: [
      config_providers: [
        {Kuddle.Config.Provider, [
          path: {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
        ]}
      ]
    ]
  ]
end
```

#### Kuddle.Config.Distillery.Provider

Used for distillery releases

```elixir
# Format
release :my_app do
  set config_providers: [
    {Kuddle.Config.Distillery.Provider, [
      path: config_path()
    ]}
  ]
end

# Example
release :my_app do
  set config_providers: [
    {Kuddle.Config.Distillery.Provider, [
      path: {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
    ]}
  ]
end
```

### Directory Loaders

#### Kuddle.Config.DirectoryProvider

```elixir
# A special config provider that will load every kdl file in a directory as config

# Format
defp releases do
  [
    application: [
      config_providers: [
        {Kuddle.Config.DirectoryProvider, [
          paths: [config_path()],
          extensions: [String.t()]
        ]}
      ]
    ]
  ]
end

# Example
defp releases do
  [
    application: [
      config_providers: [
        {Kuddle.Config.DirectoryProvider, [
          paths: [
            {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
          ],
          extensions: [".kdl", ".kuddle"]
        ]}
      ]
    ]
  ]
end
```

#### Kuddle.Config.Distillery.DirectoryProvider

```elixir
# Format
release :my_app do
  set config_providers: [
    {Kuddle.Config.Distillery.DirectoryProvider, [
      paths: [config_path()],
      extensions: [String.t()]
    ]}
  ]
end

# Example
release :my_app do
  set config_providers: [
    {Kuddle.Config.Distillery.DirectoryProvider, [
      paths: [
        {:system, "PATH_TO_CONFIG", "/default/path/to/kdl/config"}
      ],
      extensions: [".kdl", ".kuddle"]
    ]}
  ]
end
```

## Other Use Cases

Despite the original purpose of this library being the config providers, the config module itself is quite useful even without the providers:

```elixir
# Have a KDL blob you wish to load?
{:ok, config} =
  Kuddle.Config.load_config_blob("""
  application {
    node "value"
  }
  """)

[
  application: [
    node: "value"
  ]
] = config

# Have a KDL file you'd like to load?
{:ok, config} = Kuddle.Config.load_config_file("my_kdl_config.kdl")

[
  application: [
    node2: "some_other_value"
  ]
] = config

# Have a directory filled with KDL files you'd like to load into one config?
{:ok, config} = Kuddle.Config.load_config_directory("/my/kdl/configs", [".kdl", ".kuddle"])

[
  data: [
    {MyRepo, [
      database: "database",
      host: "127.0.0.1",
      port: 5432,
    ]},
  ],
  web: [
    http: [
      port: 4000
    ]
  ],
  workers: [
    amqp: [
      host: "127.0.0.1",
      port: 5732,
      virtual_host: "my_workers",
    ]
  ]
] = config

# Have the kuddle document already?
{:ok, config} = Kuddle.Config.load_config_document(document)

[
  logger: [
    console: [
      level: :debug
    ]
  ]
] = config
```

## Config Format

Root nodes are application level config, while subsequent sub nodes will be one level deeper config

```kdl
application {
  key "value"

  key2 {
    subkey "value"
  }
}
```

Is equivalent to:

```elixir
config :application,
  key: "value",
  key2: [
    subkey: "value"
  ]
```

Config is extracted from both attributes and sub nodes:

```kdl
application {
  food {
    bacon "1"
    eggs "2"
  }
}
```

Is equivalent to:

```kdl
application {
  food bacon="1" eggs="2"
}
```

Either can be mixed and matched to achieve a comfortable format:

```kdl
application {
  food bacon="1" {
    eggs "2"
  }
}
```

There is one tiny gotcha in regards to lists:

```kdl
application {
  node "value"
}
```

Would evaluate to:

```elixir
[
  application: [
    node: "value"
  ]
]
```

As one would expect, however:

```kdl
application {
  node "value" "value2"
}
```

Would evaluate to:

```elixir
[
  application: [
    node: ["value", "value2"]
  ]
]
```

Assuming the configuration requires a list, it can be coerced using the `(list)` annotation on the node:

```kdl
application {
  (list)node "value"
}
```

```elixir
[
  application: [
    node: ["value"]
  ]
]
```

Sometimes it is useful to set a tuple, which is something most available configuration languages struggle with for elixir:

```kdl
application {
  (tuple)thing "left" "right"
}
```

```elixir
[
  application: [
    thing: {"left", "right"}
  ]
]
```

You can also cast values into atoms:

```kdl
logger {
  console {
    level (atom)"debug"
  }
}
```

```elixir
[
  logger: [
    console: [
      level: :debug
    ]
  ]
]
```

A list of all available types and more information can be found in the Kuddle.Config.Types module, or the table below.

| Type Annotation  | Example                                                                       |
| ---------------- | ----------------------------------------------------------------------------- |
| `date`           | `start_date (date)"2021-09-14"`                                               |
| `utc_datetime`   | `inserted_at (utc_datetime)"2021-09-14T18:00:00.000000Z"`                     |
| `naive_datetime` | `deleted_at (naive_datetime)"2021-09-14T18:00:00.000000Z"`                    |
| `time`           | `start_time (time)"18:00:23"`                                                 |
| `decimal`        | `cost (decimal)"0.002500"`                                                    |
| `atom`           | `level (atom)"debug"`                                                         |
| `boolean`        | `enable_polling (boolean)"YES"`                                               |
| `tuple`          | `(tuple)call_pair "New York" "12003004000"`                                   |
| `list`           | `(list)allow_list "117.27.222.122"`                                           |

Additional types can be registered using `kuddle_config` `:types` config:

```elixir
config :kuddle_config,
  types: [
    geopoint: {MyGeoPoint, :cast},
  ]
```

```elixir
defmodule MyGeoPoint do
  def cast(value) do
    {:ok, String.split(value, ",", parts: 2) |> Enum.map(&Decimal.new/1) |> List.to_tuple()}
  end
end
```

```kdl
application {
  point (geopoint)"15.27,265.27"
}
```

```elixir
[
  application: [
    point: {%Decimal{coef: "1527", exp: -2, sign: 1}, %Decimal{coef: "26527", exp: -2, sign: 1}}
  ]
]
```
