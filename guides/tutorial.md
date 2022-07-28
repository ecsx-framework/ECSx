# Tutorial Project

Now that we have an Elixir project with Phoenix, we can get started on building a game with
Entity-Component-System architecture.  We're going to use the classic [Snake](https://en.wikipedia.org/wiki/Snake_(video_game_genre)) as inspiration.

## Design plan

First, let's start with a single entity.  In ECS, an entity is nothing by itself, so we must start by defining the aspects which will make up the entity.  What makes a Snake?

  * Has a physical position in the game world
  * Moves forward constantly
  * Can change direction
  * Tail grows longer over time

For each of these requirements, we will create an aspect:

```
  Position
  Moving
  Direction
  Length
```

For each of these aspects, we'll define a schema which contains the ID of the entity, and any relevant data:

  * Position: `{entity_id, x, y}` ex: `{123, 0, -50}`
  * Moving: `{entity_id, speed}` ex: `{123, 1}`
  * Direction: `{entity_id, direction}` ex: `{123, :north}`
  * Length: `{entity_id, length}` ex: `{123, 10}`

We can use the ECSx generators to quickly create the files needed for these aspects:

```console
  $ mix ecsx.gen.aspect Position entity_id x y
```

Following the above pattern, run `mix ecsx.gen.aspect` for the remaining three aspects.

Next we have to think about the Systems which will organize game logic.  What makes a Snake game work?

  * Snakes move forwards every game tick
  * Snakes get longer over time (or based on other game conditions)
  * When a collision is detected, one or both snakes are removed from the game

Each one of these will be the responsibility of a different System:

```
  ForwardMovement
  GrowTail
  Collision
```

We will generate modules for each of these Systems with `mix ecsx.gen.system`.  For example:

```console
  $ mix ecsx.gen.system ForwardMovement
```

After generating all three of our Systems, it's time to write the game logic for each one.  Head over to `lib/your_app/systems`, where your recently-generated Systems are waiting.  We'll start with `forward_movement.ex`:

```elixir
defmodule YourApp.Systems.ForwardMovement do
  ...
  alias YourApp.Aspects.Direction
  alias YourApp.Aspects.Moving
  alias YourApp.Aspects.Position
  ...
  def run do
    # First we check entities for the aspect which triggers this system
    moving = Moving.get_all()

    for %{entity_id: entity_id, speed: speed} <- moving do
      # In addition to the speed, we need some additional data about the entity
      %{direction: direction} = Direction.get_component(entity_id)
      %{x: x, y: y} = Position.get_component(entity_id)

      # Implementing this calculation is left as an exercise for the reader
      {new_x, new_y} = calculate_new_position(x, y, speed, direction)

      # Now we update the Position for the entity
      Position.remove_component(entity_id)
      Position.add_component(entity_id: entity_id, x: new_x, y: new_y)
    end
  end
end
```

Let's skip the next system `GrowTail` for now and look at `Collision`.  Without tails growing, each snake is just a 1x1 "head", and if two heads collide, they will both be removed.  Let's add logic to `Collision.run/0` to handle this case:

```elixir
defmodule YourApp.Systems.Collision do
  ...
  def run do
    # Fetch position data for all snakes
    snake_coordinates = Position.get_all()

    # Implementing this calculation is left as an exercise for the reader
    duplicates = find_duplicates(snake_coordinates)

    for %{entity_id: id, x: x, y: y} <- duplicates do
      # When snakes crash, we can remove their components
      Position.remove_component(id)
      Moving.remove_component(id)
      Direction.remove_component(id)
      Length.remove_component(id)

      # Without any components, the entity will cease to exist!
      # Maybe we would like to keep some record of the entity instead:
      CrashRecord.add_component(
        entity_id: id,
        crash_time: DateTime.utc_now(),
        crash_location: {x, y}
      )
    end
  end
end
```

Whenever we need a new Aspect (such as `CrashRecord`), we can run the generator again:

```console
  $ mix ecsx.gen.aspect CrashRecord entity_id crash_time crash_location
```
