# ECS Design

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
