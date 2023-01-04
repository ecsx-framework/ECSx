# ECS Design

## Entities and Components

Everything in your application is an Entity, but in ECS you won't work with these
Entities directly - instead you will work with the individual attributes that an Entity
might have.  These attributes are given to an Entity by creating a Component, which holds,
at minimum, the Entity's unique ID, but also can store a value.  For example:

* You're running a 2-dimensional simulation of cars on a highway
* Each car gets its own `entity_id` e.g. `123`
* If the car with ID `123` is blue, we give it a `Color` Component with value `"blue"`
* If the same car is moving west at 60mph, we might model this with a `Direction` Component with value `"west"` and a `Speed` Component with value `60`
* The car would also have Components such as `XCoordinate` and `YCoordinate` to locate it
  on the map

## Systems

Once your Entities are modeled using Components, you'll create Systems to operate on them.
For example:

* Entities with `Speed` Components should have their locations regularly updated according to the speed and direction
* We can create a `Move` System which reads the `Speed` and `Direction` Components, calculates how far the car has moved since the last server tick, and updates the Entity's `XCoordinate` and/or `YCoordinate` Component accordingly.
* The System will run every tick, only considering Entities which have a `Speed` Component
