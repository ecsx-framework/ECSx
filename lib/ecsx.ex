defmodule ECSx do
  @moduledoc """
  ECSx is an Entity-Component-System (ECS) framework for Elixir.

  In ECS:

  * Every game object is an Entity, represented by a unique ID.
  * The data which comprises an Entity is split among many Components.
  * Game logic is split into Systems, which update the Components every server tick.

  Under the hood, ECSx uses Erlang Term Storage (ETS) to store active Components in memory.
  A single GenServer manages the ETS tables to ensure strict serializability and customize
  the run order for Systems.
  """
end
