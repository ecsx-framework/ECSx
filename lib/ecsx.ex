defmodule ECSx do
  @moduledoc """
  ECSx is an Entity-Component-System (ECS) framework for Elixir. In ECS:

  * Every game object is an Entity, represented by a unique ID.
  * The data which comprises an Entity is split among many Components.
  * Game logic is split into Systems, which update the Components every server tick.

  Components are grouped together - with similar Components from other Entities - into
  categories called Aspects.  Systems can then be organized in a way where each one only
  operates on Components of a specific Aspect.

  Under the hood, ECSx uses Erlang Term Storage (ETS) to store active Components in memory.
  A single GenServer manages the ETS tables to ensure strict serializability and customize
  the run order for Systems.
  """
end
