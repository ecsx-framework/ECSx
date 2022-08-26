# ECSx

[![Hex Version](https://img.shields.io/hexpm/v/ecsx.svg)](https://hex.pm/packages/ecsx)
[![License](https://img.shields.io/hexpm/l/ecsx.svg)](https://github.com/APB9785/ECSx/blob/master/LICENSE)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/ecsx)

ECSx is an Entity-Component-System (ECS) framework for Elixir.  ECS is an architecture
for building real-time games and simulations, wherein data about Entities is stored in
small fragments called Components, which are then read and updated by Systems.

## Setup

* Add `:ecsx` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecsx, "~> 0.2"}
  ]
end
```

* Run `mix deps.get`
* Run `mix ecsx.setup`
* Add the generated Manager module to your application's supervision tree:

```elixir
def start(_type, _args) do
  children = [
    MyApp.Manager
  ]

  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

## Usage

### Entities, Aspects, and Components

Everything in your application is an Entity, but in ECS you won't work with these
Entities directly - instead you will work directly with the individual attributes
that an Entity might have.  These attributes are called Aspects, and they are given
to an Entity by creating a Component, which holds, at minimum, the Entity's
unique ID, but also any extra data which is relevant to that Aspect.  For example:

* You're running a simulation of cars on a highway
* Each car gets its own `entity_id` e.g. `123`
* If the car with ID 123 is blue, we give it the `Color` Aspect, stored as a `{123, "blue"}` Component
* If the same car is moving west at 60mph, we might model this with a `Moving` Aspect, stored as a `{123, 60, "west"}` Component
* Another car with ID 135 might have the `Moving` Aspect with different data `{135, 30, "east"}`
* These cars would also have `Location` which holds x, y, z coordinates: `{entity_id, x, y, z}`

### Systems

Once your data is modeled using Components to associate different Aspects to your Entities,
you'll create Systems to operate on them.  For example:

* Entities with the `Moving` Aspect should have their locations regularly updated according to the speed and direction
* We can create a `Move` System which reads the `Moving` Component, calculates how far the car has moved since the last server tick, and updates the Entity's `Location` Component accordingly.
* The System will run every tick, only considering Entities which have the `Moving` Aspect

### Generators

ECSx comes with generators to quickly create new Aspects or Systems:

* `mix ecsx.gen.aspect`
* `mix ecsx.gen.system`

### Manager

Every ECSx application requires a Manager module, where valid Aspects and Systems are declared,
as well as the setup to spawn world objects before any players join.  This module is created for
you during `mix ecsx.setup` and will be automatically updated by the other generators.

It is especially important to consider the order of your Systems list.  The manager will run each
System one at a time, in order.

## License

Copyright (C) 2022  Andrew P Berrien

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the [GNU General Public License](https://www.gnu.org/licenses/gpl.html) for more details.
