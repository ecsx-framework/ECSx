defmodule ECSx.ClientEvents do
  @moduledoc """
  A store to which clients can write, for communication with the ECSx backend.

  Events are created from the client process by calling `add/2`, then retrieved by the handler
  system using `get_and_clear/0`.  You will be required to create the handler system yourself -
  see the [tutorial project](web_frontend_liveview.html#handling-client-events) for a detailed example.
  """
  use GenServer

  @type id :: any()

  @doc false
  def start_link(_), do: ECSx.Manager.start_link(__MODULE__)

  @doc false
  def init(_), do: {:ok, []}

  @doc false
  def handle_cast({:add, entity, value}, state) do
    {:noreply, [{entity, value} | state]}
  end

  @doc false
  def handle_call(:get_and_clear, _from, state) do
    {:reply, Enum.reverse(state), []}
  end

  @doc """
  Add a new client event.

  The first argument is the entity which spawned the event.
  The second argument can be any representation of the event, usually either an atom or a tuple
  containing an atom name along with additional metadata.

  ## Examples

      # Simple event requiring no metadata
      ECSx.ClientEvents.add(player_id, :spawn_player)

      # Event with metadata
      ECSx.ClientEvents.add(player_id, {:send_message_to, recipient_id, message})

  """
  @spec add(id(), any()) :: :ok
  def add(entity, event), do: GenServer.cast(__MODULE__, {:add, entity, event})

  @doc """
  Returns the list of events, simultaneously clearing it.

  This function guarantees that each event is returned exactly once.
  """
  @spec get_and_clear() :: [{id(), any()}]
  def get_and_clear, do: GenServer.call(__MODULE__, :get_and_clear)
end
