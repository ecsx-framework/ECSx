# Tutorial Project

Now that we have an Elixir project with Phoenix, we can get started on building a game with
Entity-Component-System architecture.  We're going to use the classic [Snake](https://en.wikipedia.org/wiki/Snake_(video_game_genre)) as inspiration.

## Design plan

In a classic Snake game, collision is everything.  We're going to need a game world where a snake
can occupy many coordinates, and each one of those coordinates should be considered for collision.
We also need to "order" each occupied coordinate in order to simulate movement - by adding to the
head and removing from the tail.

Let's start by creating a `Coordinate` aspect:

```console
  $ mix ecsx.gen.aspect Coordinate coordinate snake_id order
```

We are declaring three fields in the schema, `coordinate`, `snake_id`, and `order`.  Normally,
the first field of a schema is `entity_id`, which will give us efficient lookups on that field.
However, this is a rare exception where lookup by `entity_id` is not very useful, and it is
`coordinate` which will be the basis for our querying.  The id of the snake is still useful
metadata, so we'll include that as the second field.  The third field is unique to our Snake game,
where each coordinate represents just one link to a longer chain that is a snake.  We need to be
able to know the first (head) and last (tail) coordinates, and we accomplish this through `order`.
A coordinate with `order` 1 is the head, and a coordinate where `order` is equal to the total
length of the snake, must be the tail.

Since we know that snake length will be useful data, let's create another Aspect for it:

```console
  $ mix ecsx.gen.aspect Length snake_id length
```

This is a standard Aspect where we will query its Components by `snake_id`, so that should be
the first field.

Next we can also anticipate needing to label snakes with a `Direction` of movement:

```console
  $ mix ecsx.gen.aspect Direction snake_id direction
```

Now that we have modeled world data and snake data, let's think about the Systems which will
organize game logic.  What makes a Snake game work?

  * Snakes move forwards every game tick
  * Snakes get longer over time (or based on other game conditions)
  * When there is a collision, one or both snakes are removed from the game

Let's start with the most important System - the physics.  We'll call it `Driver`:

```console
  $ mix ecsx.gen.system Driver
```

Heading over to the generated file `lib/your_app/systems/driver.ex` and we'll add some code:

```elixir
defmodule YourApp.Systems.Driver do
  ...
  alias YourApp.Aspects.Moving
  alias YourApp.Aspects.Position
  ...
  def run do
    # First we get all the Coordinate components
    coordinates = Coordinate.query_all()

    # Each coordinate will be appropriately updated to simulate the movement of the snakes
    Enum.each(coordinates, &update_coordinate/1)
  end

  defp update_coordinate(%{coordinate: {x, y}, snake_id: id, order: 1} = component) do
    # If the order is 1, then this is a head;  we need to occupy an adjacent coordinate.
    # First let's find the direction this snake is headed
    direction = Direction.query_one(match: [snake_id: id], value: :direction)

    # From this direction we need to calculate the coordinate we're moving into
    new_coord = calculate_new_position(x, y, direction)

    # Insert new head coordinate and increment the order of this one
    Coordinate.add_component(coordinate: new_coord, snake_id: id, order: 1)
    increment_order(component)
  end

  defp update_coordinate(%{coordinate: coordinate, snake_id: id, order: order} = component) do
    # Since we know this isn't the head, we just need to check if it's the tail
    length = Length.query_one(match: [snake_id: id], value: :length)

    if length == order do
      # This is the tail, we should un-occupy the coordinate as the snake moves out
      Coordinate.remove_component(coordinate: coordinate, snake_id: id)
    else
      # All other coordinates in-between get their order incremented by one
      increment_order(component)
    end
  end

  defp calculate_new_position(x, y, :north), do: {x, y + 1}
  defp calculate_new_position(x, y, :east), do: {x + 1, y}
  defp calculate_new_position(x, y, :south), do: {x, y - 1}
  defp calculate_new_position(x, y, :west), do: {x - 1, y}

  defp increment_order(%{coordinate: coordinate, snake_id: id, order: order}) do
    Coordinate.remove_component(coordinate: coordinate, snake_id: id)
    Coordinate.add_component(coordinate: coordinate, snake_id: id, order: order + 1)
  end
end
```

You probably noticed that this System creates new coordinates without checking if there is any
collision with existing coordinates.  This is intentional;  to demonstrate why, imagine an
example where Snake A is exiting a coordinate, and Snake B is entering the same coordinate,
on the same server tick.  Now, if we check for collision in the `Driver` system, the result will
depend on which Component gets updated first:

  * If Snake A's tail Component is updated first, then the check will show the coordinate as
    unoccupied, and there will be no collision.
  * If Snake B's head Component is updated first, then the check will show the coordinate as
    occupied by Snake A's tail, and there will be a collision.

We want to avoid this kind of inconsistency, and ensure that the result is the same, regardless
of which Component is stored earlier in the table.  Therefore we allow duplicate coordinates,
and will have another System handle the cleanup afterwards.

You've probably guessed that we'll start by running the generator:

```console
  $ mix ecsx.gen.system Collision
```

But before we start coding, let's think of a plan for how to efficiently check for collisions.
One approach could be to fetch all the Coordinate Components, iterate over the list, grouping
them by `{x, y}` pair, then iterate over the groups, checking if any have more than one member.
This might be fine for some games, but if we want to optimize performance, we should only check
for collision where there is actually a possibility of collision.  The only possible points of
collision are those coordinates where there is a snake head (order 1).

Then, in `lib/your_app/systems/collision.ex`:

```elixir
defmodule YourApp.Systems.Collision do
  ...
  def run do
    # Fetch coordinates for all snake heads
    possible_collision_coords = Coordinate.query_all(match: [order: 1])
    # Update components for any entities which have collided
    Enum.each(possible_collision_coords, &check_for_collision/1)
  end

  defp check_for_collision(%{coordinate: coordinate, snake_id: id, order: order}) do
    case Coordinate.query_all(match: [coordinate: coordinate]) do
      [] -> :ok
      [_] -> :ok
      multiple_results -> Enum.each(multiple_results, &handle_collision/1)
    end
  end

  defp handle_collision(%{coordinate: coordinate, snake_id: id, order: 1}) do
    # When a snake head collides, it dies - we can remove its components
    Position.remove_component(id)
    Moving.remove_component(id)
    Length.remove_component(id)

    # Without any components, the entity will cease to exist!
    # Maybe we would like to keep some record of the entity instead:
    CrashRecord.add_component(
      entity_id: id,
      crash_time: DateTime.utc_now(),
      crash_location: coordinate
    )
  end

  # If the order is not 1, then the collision was on the snake's tail, and it will survive
  defp handle_collision(_), do: :ok
end
```

Whenever we need a new Aspect (such as `CrashRecord`), we can simply run the generator again:

```console
  $ mix ecsx.gen.aspect CrashRecord entity_id crash_time crash_location
```
