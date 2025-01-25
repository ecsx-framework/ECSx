# Changelog

## v0.5.2 (2025-01-25)

  * Fixed an issue where Components with `index: true` were not fully removed with `Component.remove/1`

## v0.5.1 (2024-01-24)

  * Fixed an issue where some Component or System naming patterns could prevent generators from working properly
  * Replace deprecated function which was causing compiler warnings (h/t @hl)

## v0.5 (2023-09-23)

  * Non-unique Component types are no longer allowed (see the [upgrade guide](upgrade_guide.html))
  * Component modules now accept option `:index` to index components for better `search/2` performance
  * `mix ecsx.gen.component` now accepts option `--index` to automatically set `index: true`
  * Component callback `get_one/2` has been renamed `get/2`
  * Systems' `run/0` no longer requires `:ok` return value
  * Manager `setup/0` and `startup/0` no longer require `:ok` return value

## v0.4 (2023-06-02)

  * Adding ECSx.ClientEvents to your supervision tree is no longer required  
  * Adding the manager to your supervision tree is no longer required  
  * Running a generator before ecsx.setup will now raise an error   
  * Added telemetry events  
  * Added component persistence, by default saving a binary file to disk  
  * Persistence file is loaded on app startup  
  * The interval between saves can be set via application config  
  * Tick rate is now set in application config  
  * Manager module (and optional custom path) are now defined in application config  
  * Added functions `tick_rate/0`, `manager/0`, `persist_interval/0`, and `manager_path/0` to the `ECSx` module for reading the configured values at runtime  
  * Added callback `add/3` for components and tags, which accepts `persist: true` option, marking the component/tag for persistence across app reboots  
  * `get_one/1` now raises an error if no results are found  
  * Added `Component` callback `get_one/2` which accepts a default value to return if no results are found  
  * `add/{2,3}` now raises if `unique: true` and the component already exists  
  * Added `Component` callback `update/2` for updating an existing component's value, while maintaining the previously set `:persist` option  
  * Manager `setup` macro is now an optional callback `setup/0` which only runs once, at the server's first startup  
  * Added a new Manager callback `startup/0` which runs every time the server starts  
  * Added `Component` callbacks `between/2`, `at_least/1`, and `at_most/1` (only available for integer and float component types)

## v0.3.1 (2023-01-12)

  * Added ECSx.ClientEvents: ephemeral components created by client processes to communicate user input/interaction with the ECSx backend  
  * ECSx.QueryError renamed to ECSx.MultipleResultsError  

## v0.3.0 (2023-01-03)

  * Components are now stored as key-value pairs  
  * Component values now require a type declaration which is checked on insertions  
  * Simplified API for working with components  
  * Aspects have been renamed to Component Types  
  * Added Tags: boolean component types which don't store any value  
  * Component `table_type` now toggled via `:unique` flag  

## v0.2.0 (2022-08-26)

  * New Query API for fetching Components  
  * Improved generators to better handle code injection  
  * Generators now raise helpful error messages when missing arguments  

## v0.1.1 (2022-07-21)

  * Setup task `mix ecsx.setup` no longer generates sample modules  
  * Added option `mix ecsx.setup --no-folders` to prevent generating folders during setup  
  * Added guides and other documentation  

## v0.1.0 (2022-07-15)

Initial release  
