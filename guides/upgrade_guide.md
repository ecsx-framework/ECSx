# Upgrade Guide

## 0.3.x to 0.4

In `manager.ex`:

  * `setup do` should be changed to `def startup do`
  * Remove the `:tick_rate` option if it is set
  * If the `:tick_rate` option was not the default of 20, add `config :ecsx, tick_rate: n` to your `config.exs`, where n is your chosen tick rate

In `application.ex`:

  * If the list of children in `start/2` contains `ECSx.ClientEvents` or `YourApp.Manager`, remove them

Component read/write changes:

  * Any use of `MyComponent.get_one(entity)` where `nil` was a possibility, should be replaced with `MyComponent.get_one(entity, nil)`
  * Any use of `MyComponent.add(entity, value)` to update the value of a unique component, should be replaced with `MyComponent.update(entity, value)`.  If the `add/2` call was used in a way where sometimes it would create new components, and other times update those components, you will need to separate the two cases to use `add/2` only for the initial creation, and then `update/2` for all subsequent updates.
  