# v0.3.0

This release was done immediately after 0.2.0 due to some seriously broken behaviour with module keys.

* Corrected behaviour of `{:system, name}`, and `{:system, name, default}`
  The former was unsupported, despite being present in the examples and documentation, while the latter did not match the example usage's expected behaviour.

* Fixed Module names being treated as opaque atoms when used in config files

```kdl
my_application {
  Module.A {
    value 1
  }
}
```

Now works as intended, at the moment there is no way to achieve the old behaviour and no immediate plans to provide a fallback.

# v0.2.0

For this release it was a matter of adding distillery config providers, instead of modifying the existing ones to keep the code straightforward.

* Added `Kuddle.Config.Distillery.Provider`
* Added `Kuddle.Config.Distillery.DirectoryProvider`

# v0.1.0

* Initial Version
