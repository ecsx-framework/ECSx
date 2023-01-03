# Tutorial Project

Now that we have an Elixir project with Phoenix, we can get started on building a game with Entity-Component-System architecture. In our game, each player will control a ship, which can sail around the map, and will attack enemies if they come too close.

> Note:  This guide will get you up-and-running with a working game, but it is intentionally generic.  Feel free to experiment with altering details from this implementation to customize your own game.

## Defining Component Types

First let's consider the basic properties of a ship:

  * Hull Points:  How much damage can it take before it is destroyed
  * Armor Rating:  How much is each incoming attack reduced by the ship's defenses
  * Attack Damage:  How much damage does its weapon deal to enemies
  * Attack Range:  How close must enemies get before the weapon can attack
  * Attack Speed:  How much time must you wait in-between attacks
  * X Position:  The horizontal position of the ship
  * Y Position:  The vertical position of the ship
  * X Velocity:  The speed at which the ship is moving, horizontally
  * Y Velocity:  The speed at which the ship is moving, vertically

Let's start by creating integer component types for each one of these (feel free to use `float` type instead, if desired):

```console
  $ mix ecsx.gen.component HullPoints integer
  $ mix ecsx.gen.component ArmorRating integer
  $ mix ecsx.gen.component AttackDamage integer
  $ mix ecsx.gen.component AttackRange integer
  $ mix ecsx.gen.component AttackSpeed integer
  $ mix ecsx.gen.component XPosition integer
  $ mix ecsx.gen.component YPosition integer
  $ mix ecsx.gen.component XVelocity integer
  $ mix ecsx.gen.component YVelocity integer
```

For now, this is all we need to do.  The ECSx generator has automatically set you up with modules for each component type, complete with a simple interface for handling the components.  We'll see this in action soon.

## Our First System

Having set up the component types which will model our game data, let's think about the Systems which will organize game logic.  What makes our game work?

  * Ships change position based on velocity
  * Ships target other ships for attack when they are within range
  * Ships with valid targets should attack the target, reducing its hull points
  * Ships with zero or less hull points are destroyed
  * Players change the velocity of their ship using an input device
  * Players can see a display of the area around their ship

Let's start with changing position based on velocity.  We'll call it `Driver`:

```console
  $ mix ecsx.gen.system Driver
```

Head over to the generated file `lib/my_app/systems/driver.ex` and we'll add some code:

```elixir
defmodule MyApp.Systems.Driver do
  ...
  use ECSx.System

  alias MyApp.Components.XPosition
  alias MyApp.Components.YPosition
  alias MyApp.Components.XVelocity
  alias MyApp.Components.YVelocity

  def run do
    for {entity, x_velocity} <- XVelocity.get_all() do
      x_position = XPosition.get_one(entity)
      new_x_position = x_position + x_velocity
      # By default, an entity can only have one component of each type.  
      # Adding a second will overwrite the first.
      XPosition.add(entity, new_x_position)
    end

    # Once the x-values are updated, do the same for the y-values
    for {entity, y_velocity} <- YVelocity.get_all() do
      y_position = YPosition.get_one(entity)
      new_y_position = y_position + y_velocity
      YPosition.add(entity, new_y_position)
    end
  end
end
```

Now whenever a ship gains velocity, this system will update the position accordingly over time.  Keep in mind that the velocity is relative to the server's tick rate, which by default is 20.  This means the unit of measurement is "game units per 1/20th of a second".

For example, if you want the speed to move from XPosition 0 to XPosition 100 in one second, you divide the distance 100 by the tick rate 20, to see that an XVelocity of 5 is appropriate.  The tick rate can be changed in `lib/my_app/manager.ex`.

## Targeting & Attacking

Next let's move on to a more complicated part of the game - attacking.  We'll start by considering the conditions which must be met in order to attack a given target:

  * Target must be a ship
  * Target must be within your ship's attack range
  * You must not have attacked too recently (based on attack speed)

For each of these conditions, we want to use the presence or absence of a component as the signal to a system that action is to be taken.  For example, in the Driver system, these were the Velocity components - for each Velocity component, we made a Position update.  

First, for determining whether a given entity is a ship, we will simply use the existing HullPoints component, because only ships will have HullPoints.

Second, for confirming the attack range, we'll make a new component type SeekingTarget which will signal to a Targeting system that a ship's proximity to other ships must be continuously calculated until a valid target is found.  Then another new component type AttackTarget will replace SeekingTarget, signaling to the Targeting system that we no longer need to check for new targets.  Instead, an Attacking system will detect the AttackTarget and handle the final step of the attacking process.

The final attack requirement is that after a successful attack, the ship's weapon must wait for a cooldown period, based on the attack speed.  To model this cooldown period, we will create an AttackCooldown component type, which will store the time at which the cooldown expires.

With this plan in place, let's go ahead and create the component types, starting with SeekingTarget.  Since the presence of this component alone fulfills its purpose, without the need to store additional data, this is the appropriate use-case for a `Tag`:

```console
  $ mix ecsx.gen.tag SeekingTarget
```

Once a target is found, the `AttackTarget` component will be needed, and this time a `Tag` will not be enough, because we need to store the ID of the target.  Likewise with `AttackCooldown`, which must store the timestamp of the cooldown's expiration.

```console
  $ mix ecsx.gen.component AttackTarget binary
  $ mix ecsx.gen.component AttackCooldown datetime
```

> Note:  In our case, we're using binary IDs to represent Entities, and Elixir `DateTime` structs for cooldown expirations.  If you're planning on using different types, such as integer IDs for entities, or storing timestamps as integers, simply adjust the parameters accordingly.

Before we set up the systems, let's make a helper module for storing any shared mathematical logic.  In particular, we'll need a function for calculating the distance between two entities.  This will come in handy for several systems in the future.

```elixir
defmodule MyApp.SystemUtils do
  @moduledoc """
  Useful math functions used by multiple systems.
  """

  alias MyApp.Components.XPosition
  alias MyApp.Components.YPosition

  def distance_between(entity_1, entity_2) do
    x_1 = XPosition.get_one(entity_1)
    x_2 = XPosition.get_one(entity_2)
    y_1 = YPosition.get_one(entity_1)
    y_2 = YPosition.get_one(entity_2)

    x = abs(x_1 - x_2)
    y = abs(y_1 - y_2)

    :math.sqrt(x ** 2 + y ** 2)
  end
end
```

Now we're onto the Targeting system, which operates only on entities with the SeekingTarget component, checking the distance to all other ships, and comparing them to the entity's attack range.  When an enemy ship is found to be within range, we can remove SeekingTarget and replace it with an AttackTarget:

```console
  $ mix ecsx.gen.system Targeting
```

```elixir
defmodule MyApp.Systems.Targeting do
  ...
  use ECSx.System

  alias MyApp.Components.AttackRange
  alias MyApp.Components.AttackTarget
  alias MyApp.Components.HullPoints
  alias MyApp.Components.SeekingTarget
  alias MyApp.SystemUtils

  def run do
    for entity <- SeekingTarget.get_all() do
      attempt_target(entity)
    end
  end

  defp attempt_target(self) do
    case look_for_target(self) do
      nil -> :noop
      {target, _hp} -> add_target(self, target)
    end
  end 

  defp look_for_target(self) do
      # For now, we're assuming anything which has HullPoints can be attacked
      HullPoints.get_all()
        # ... except your own ship!
      |> Enum.reject(fn {possible_target, _hp} -> possible_target == self end)
      |> Enum.find(fn {possible_target, _hp} ->
          distance_between = SystemUtils.distance_between(possible_target, self)
          range = AttackRange.get_one(self)

          distance_between < range
        end
      end
  end

  defp add_target(self, target) do
    SeekingTarget.remove(self)
    AttackTarget.add(self, target)
  end
end
```

The Attacking system will also check distance, but only to the target ship, in case it has moved out-of-range.  If not, we just need to check on the cooldown, and do the attack.

```console
  $ mix ecsx.gen.system Attacking
```

```elixir
defmodule MyApp.Systems.Attacking do
  ...
  use ECSx.System

  alias MyApp.Components.ArmorRating
  alias MyApp.Components.AttackCooldown
  alias MyApp.Components.AttackDamage
  alias MyApp.Components.AttackRange
  alias MyApp.Components.AttackSpeed
  alias MyApp.Components.AttackTarget
  alias MyApp.Components.HullPoints
  
  
  def run do
    for {attacker, target} <- AttackTarget.get_all() do
      attack_if_ready(attacker, target)
    end
  end

  defp attack_if_ready(self, target) do
    cond do
      SystemUtils.distance_between(self, target) > AttackRange.get_one(self) ->
        # If the target ever leaves our attack range, we want to remove the AttackTarget
        # and begin searching for a new one.
        AttackTarget.remove(self)
        SeekingTarget.add(self)

      AttackCooldown.exists?(self) ->
        # We're still within range, but waiting on the cooldown
        :noop

      :otherwise ->
        do_attack(self, target)
    end
  end

  defp do_attack(self, target) do
    damage = AttackDamage.get_one(self)
    # Assuming one armor rating always equals one damage
    reduction_from_armor = ArmorRating.get_one(target)
    final_damage = damage - reduction_from_armor

    target_current_hp = HullPoints.get_one(target)
    target_new_hp = target_current_hp - final_damage

    HullPoints.add(target, target_new_hp)

    attack_speed = AttackSpeed.get_one(self)
    cooldown_until = DateTime.utc_now() + attack_speed
    AttackCooldown.add(self, cooldown_until)
  end
end
```

Phew, that was a lot!  But we're still using the same basic concepts:  `get_all/0` to fetch the list of all relevant entities, then `get_one/1` and `exists?/1` to check specific attributes of the entities, and finally `add/2` for creating new components, or overwriting existing ones.  We're also starting to see the use of `remove/1` for excluding an entity from game logic which is no longer necessary.

## Cooldowns

Our attacking system will add a cooldown with an expiration timestamp, but the next step is to ensure the cooldown component is removed from the entity once the time is reached, so it can attack again.  For that, we'll create a `CooldownExpiration` system:

```console
  $ mix ecsx.gen.system CooldownExpiration
```

> Note: going forwards, aliases will be omitted from the examples to save space.  Don't forget to include the required aliases for your component types!

```elixir
defmodule MyApp.Systems.CooldownExpiration do
  ...
  def run do
    now = DateTime.utc_now()

    for {entity, timestamp} <- AttackCooldown.get_all() do
      case DateTime.compare(now, timestamp) do
        :lt -> :noop
        _ -> AttackCooldown.remove(entity)
      end
    end
  end
end
```

This system will check the cooldowns on each game tick, removing them as soon as the expiration time is reached.

## Death & Destruction

Next let's handle what happens when a ship has its HP reduced to zero or less:

```console
  $ mix ecsx.gen.component DestroyedAt datetime
```

```console
  $ mix ecsx.gen.system Destruction
```

```elixir
defmodule MyApp.Systems.Destruction do
  ...
  def run do
    for {entity, hp} <- HullPoints.get_all() do
      if hp <= 0, do: destroy(entity)
    end
  end

  defp destroy(entity) do
    ArmorRating.remove(entity)
    AttackCooldown.remove(entity)
    AttackDamage.remove(entity)
    AttackRange.remove(entity)
    AttackSpeed.remove(entity)
    AttackTarget.remove(entity)
    HullPoints.remove(entity)
    SeekingTarget.remove(entity)
    XPosition.remove(entity)
    XVelocity.remove(entity)
    YPosition.remove(entity)
    YVelocity.remove(entity)

    # when a ship is destroyed, other ships should stop targeting it
    untarget(entity)

    DestroyedAt.add(entity, DateTime.utc_now()
  end

  defp untarget(target) do
    for entity <- AttackTarget.search(target) do
      AttackTarget.remove(entity)
      SeekingTarget.add(entity)
    end
  end
end
```

In this example we remove all the components the entity might have, then add a new DestroyedAt component with the current timestamp.  If we wanted some components to persist - such as the position and/or velocity, so the wreckage could still be visible on the player displays - we could keep them around and possibly have another system clean them up later on.  Likewise if there were other components to add, such as a `RespawnTimer` or `FinalScore`, we could add them here as well.

## Initializing Components

By now you might be wondering "How did those components get created in the first place?"  We have code for adding `AttackCooldown` and `DestroyedAt`, when needed, but the basic components for the ships still need to be added before the game can even start.  For that, we'll check out `lib/my_app/manager.ex`:

```elixir
defmodule MyApp.Manager do
  ...
  use ECSx.Manager, tick_rate: 20

  setup do
    # Load your initial components
  end

  def components do
    ...
  end

  def systems do
    ...
  end
end
```

This module holds four critical pieces of data - the server's tick rate, data initialization, a list of every valid component type, and a list of each game system in the order they are to be run.  Let's initialize some ship data inside the `setup` block:

```elixir
setup do
  for _player_count <- 1..4 do
    # First generate a unique ID to represent the new entity
    entity = Ecto.UUID.generate()

     # Then use that ID to create the components which make up a ship    
    ArmorRating.add(entity, 0)
    AttackDamage.add(entity, 5)
    AttackRange.add(entity, 10)
    AttackSpeed.add(entity, 1000)
    AttackTarget.add(entity, nil)
    HullPoints.add(entity, 50)
    XPosition.add(entity, Enum.random(1..100))
    XVelocity.add(entity, 0)
    YPosition.add(entity, Enum.random(1..100))
    YVelocity.add(entity, 0)
  end
end
```

Now when the server starts, there will be four ships set up and ready to go.

## Coming Soon

I/O, display
