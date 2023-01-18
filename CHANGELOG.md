# Changelog

## Unreleased

Adding ECSx.ClientEvents to the supervision tree is no longer required

## v0.3.1 (2023-01-12)

Added ECSx.ClientEvents: ephemeral components created by client processes to communicate user input/interaction with the ECSx backend  
ECSx.QueryError renamed to ECSx.MultipleResultsError  

## v0.3.0 (2023-01-03)

Components are now stored as key-value pairs  
Component values now require a type declaration which is checked on insertions  
Simplified API for working with components  
Aspects have been renamed to Component Types  
Added Tags: boolean component types which don't store any value  
Component `table_type` now toggled via `:unique` flag  

## v0.2.0 (2022-08-26)

New Query API for fetching Components  
Improved generators to better handle code injection  
Generators now raise helpful error messages when missing arguments  

## v0.1.1 (2022-07-21)

Setup task `mix ecsx.setup` no longer generates sample modules  
Added option `mix ecsx.setup --no-folders` to prevent generating folders during setup  
Added guides and other documentation  

## v0.1.0 (2022-07-15)

Initial release  
