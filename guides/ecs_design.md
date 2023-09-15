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

## one-to-many associations

At some point, you might find yourself thinking of adding multiple Components of the same type to a
single Entity.  We'll call this a "one-to-many" association - as in, one Entity, many Components.
For example:

Let's say you have a fantasy game where the hero wields a weapon in one hand, and a shield in the
other hand.  At first, you create a Component for each

```elixir
Weapon.add(hero_entity, "Longsword")
Shield.add(hero_entity, "Buckler")
```

and move on to other features.  However, later on you decide to implement a dual-wielding mechanic
where the hero can wield two swords at a time.  You briefly consider creating a new Component type
called `OffhandWeapon` to go alongside the primary `Weapon`, but then remember that eventually the
hero will encounter monsters with more than two arms!  Also there is a feature request for weapons
to be magically enchanted, and eventually you'd also like equipment to lose durability over time and
require repairs at the blacksmith.  So, creating a new Component type for each weapon slot is only
a temporary workaround which is not a very robust solution.

The ideal solution here is to think about the weapons not as Components, but as separate Entities.
When the hero equips a sword, create a new entity reference for that sword, and reference back
to the hero entity with one of the sword's Components.

```elixir
sword_entity = Ecto.UUID.generate()
Description.add(sword_entity, "Longsword")
EquippedBy.add(sword_entity, hero_entity)
```

Now if the hero gets a second sword, we can repeat the process:

```elixir
another_sword_entity = Ecto.UUID.generate()
Description.add(another_sword_entity, "Shortsword")
EquippedBy.add(another_sword_entity, hero_entity)
```

Fetching a list of weapons equipped by the hero can then be done with `EquippedBy.search(hero_entity)`

To implement weapon durability:

```elixir
Durability.add(sword_entity, 150)
Durability.add(another_sword_entity, 75)
```

Implementing magic enchantments presents the same situation:  we could add a Component to the sword,
but this only works for one simple enchantment per weapon.  In order to allow multiple enchantments
per weapon, with arbitrary enchantment complexity, we should think about each enchantment as an
Entity.

```elixir
enchantment_entity = Ecto.UUID.generate()
Description.add(enchantment_entity, "Firaga")
EnchantTarget.add(enchantment_entity, sword_entity)
```

