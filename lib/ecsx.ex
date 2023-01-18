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
  use Application

  @doc false
  def start(_type, _args) do
    children = [
      ECSx.ClientEvents
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: ECSx.Supervisor)
  end
end
