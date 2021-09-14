# Kuddle Config

An Elixir `Config.Provider` using kuddle, also general configuration helpers using Kuddle.

## Installation

To add `kuddle_config` to your project:

```elixir
def deps do
  [
    {:kuddle_config, "~> 0.1.0"}
  ]
end
```

## Usage

Kuddle provides 2 different config providers:

```elixir
# The default Config.Provider which will load a kdl file as config
Kuddle.Config.Provider
```

```elixir
# A special config provider that will load every kdl file in a directory as config
Kuddle.Config.DirectoryProvider
```
