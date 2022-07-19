# ECS Design

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
