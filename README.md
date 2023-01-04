# ECSx

[![Hex Version](https://img.shields.io/hexpm/v/ecsx.svg)](https://hex.pm/packages/ecsx)
[![License](https://img.shields.io/hexpm/l/ecsx.svg)](https://github.com/APB9785/ECSx/blob/master/LICENSE)
[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/ecsx)

ECSx is an Entity-Component-System (ECS) framework for Elixir.  ECS is an architecture for building real-time games and simulations, wherein data about Entities is stored in small fragments called Components, which are then read and updated by Systems.

## Setup

* Add `:ecsx` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecsx, "~> 0.3"}
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

### Entities and Components

Everything in your application is an Entity, but in ECS you won't work with these Entities directly - instead you will work with the individual attributes that an Entity might have.  These attributes are given to an Entity by creating a Component, which holds, at minimum, the Entity's unique ID, but also can store a value.  For example:

* You're running a 2-dimensional simulation of cars on a highway
* Each car gets its own `entity_id` e.g. `123`
* If the car with ID `123` is blue, we give it a `Color` Component with value `"blue"`
* If the same car is moving west at 60mph, we might model this with a `Direction` Component with value `"west"` and a `Speed` Component with value `60`
* The car would also have Components such as `XCoordinate` and `YCoordinate` to locate it on the map

### Systems

Once your Entities are modeled using Components, you'll create Systems to operate on them.  For example:

* Entities with `Speed` Components should have their locations regularly updated according to the speed and direction
* We can create a `Move` System which reads the `Speed` and `Direction` Components, calculates how far the car has moved since the last server tick, and updates the Entity's `XCoordinate` and/or `YCoordinate` Component accordingly.
* The System will run every tick, only considering Entities which have a `Speed` Component

### Generators

ECSx comes with generators to quickly create new Components or Systems:

* `mix ecsx.gen.component`
* `mix ecsx.gen.system`

### Manager

Every ECSx application requires a Manager module, where valid Component types and Systems are declared, as well as the setup to spawn world objects before any players join.  This module is created for you during `mix ecsx.setup` and will be automatically updated by the other generators.

It is especially important to consider the order of your Systems list.  The manager will run each System one at a time, in order.

## Tutorial Project

Note: This tutorial project is a work-in-progress  
[Building a ship combat engine with ECSx in a Phoenix app](https://hexdocs.pm/ecsx/tutorial.html)

## License

Copyright (C) 2022  Andrew P Berrien

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the [GNU General Public License](https://www.gnu.org/licenses/gpl.html) for more details.
