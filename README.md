# ECSx

ECSx is an Entity-Component-System (ECS) framework for Elixir.  ECS is an architecture
for building real-time games and simulations, wherein data about Entities is stored in
small fragments called Components, which are then read and updated by Systems.

## Setup

### Adding ECSx to an existing project

* Add `{:ecsx, github: "APB9785/ECSx"}` to your deps (Hex install coming soon)
* Run `mix deps.get`
* Run `mix ecsx.setup`
* Add the generated module `YourApp.Manager` to your application's supervision tree

### Creating a new ECSx project

* Coming soon!

## Usage

### Entities, Aspects, and Components

Everything in your application is an entity, but in ECS you won't work with these
entities directly - instead you will work directly with the individual attributes
that an entity might have.  These attributes are called aspects, and they are given
to an entity by creating a component, which holds, at minimum, the entity's
unique ID, but also any extra data which is relevant to that aspect.  For example:

* You're running a simulation of cars on a highway
* Each car gets its own `entity_id` e.g. `123`
* If the car with ID 123 is blue, we give it the `Color` aspect, stored as a `{123, "blue"}` component
* If the same car is moving west at 60mph, we might model this with a `Moving` aspect, stored as a `{123, 60, "west"}` component
* Another car with ID 135 might have the `Moving` aspect with different data `{135, 30, "east"}`
* These cars would also have `Location` which holds x, y, z coordinates: `{entity_id, x, y, z}`

### Systems

Once your data is modeled using components to associate different aspects to your entities,
you'll create systems to operate on them.  For example:

* Entities with the `Moving` aspect should have their locations regularly updated according to the speed and direction
* We can create a `Move` system which reads the `Moving` component, calculates how far the car has moved since the last server tick, and updates the entity's `Location` component accordingly.
* The system will run every tick, only considering entities which have the `Moving` aspect

### Generators

ECSx comes with generators to quickly create new aspects or systems:

* `mix ecsx.gen.aspect`
* `mix ecsx.gen.system`

### Manager

Every ECSx application requires a Manager module, where valid aspects and systems are declared,
as well as the setup to spawn world objects before any players join.  This module is created for
you during `mix ecsx.setup` and will be automatically updated by the other generators.

It is especially important to consider the order of your systems list.  The manager will run each
system one at a time, in order.
