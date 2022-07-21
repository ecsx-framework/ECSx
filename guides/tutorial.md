# Tutorial Project

Now that we have an Elixir project with Phoenix, we can get started on building a game with
Entity-Component-System architecture.  We're going to use the classic [Snake](https://en.wikipedia.org/wiki/Snake_(video_game_genre)) as inspiration.

## Design plan

First, let's start with a single entity.  In ECS, an entity is nothing by itself, so we must start by defining the aspects which will make up the entity.  What makes a Snake?

  * Has a physical position in the game world
  * Moves forward constantly
  * Can change direction
  * Tail grows longer over time
  * Kills other snakes when they touch its tail

For each of these requirements, we will create an aspect:

  Position
  Moving
  Direction
  Length
  OnContact

For each of these aspects, we'll define a schema which contains the ID of the entity, and any relevant data:

  Position: `{entity_id, x, y}` ex: `{123, 0, -50}`
  Moving: `{entity_id, speed}` ex: `{123, 1}`
  Direction: `{entity_id, direction}` ex: `{123, :north}`
  Length: `{entity_id, length}` ex: `{123, 10}`
  OnContact: `{entity_id, result_of_contact}` ex: `{123, :death}`

We can use the ECSx generators to quickly create the files needed for these aspects:

```console
  $ mix ecsx.gen.aspect Position entity_id x y
```

Following the above pattern, run `ecsx.gen.aspect` for the remaining four aspects.

Next we have to think about the Systems which will organize game logic.  What makes a Snake game work?

  * Snakes move forwards every game tick
  * Snakes change direction when a player gives input
  * Snakes get longer over time (or based on other game conditions)
  * When a collision is detected, one or both snakes are removed from the game

Each one of these will be the responsibility of a different System:

  ForwardMovement
  PlayerInput
  GrowTail
  Collision

We will generate modules for each of these Systems with `ecsx.gen.system`.  For example:

```console
  $ mix ecsx.gen.system ForwardMovement
```

After generating all four of our Systems, it's time to write the game logic for each one - COMING SOON
