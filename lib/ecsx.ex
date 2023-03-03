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
    children = [ECSx.ClientEvents] ++ List.wrap(ECSx.manager() || [])

    Supervisor.start_link(children, strategy: :one_for_one, name: ECSx.Supervisor)
  end

  @doc """
  Returns the ECSx manager module.

  This is set in your app configuration:

  ```elixir
  config :ecsx, manager: MyApp.Manager
  ```
  """
  @spec manager() :: module() | nil
  def manager do
    case Application.get_env(:ecsx, :manager) do
      {module, path: _} when is_atom(module) -> module
      module_or_nil when is_atom(module_or_nil) -> module_or_nil
    end
  end

  @doc """
  Returns the path to the ECSx manager file.

  This is inferred by your module name.  If you want to rename or move the
  manager file so the path and module name are no longer in alignment, use
  a custom `:path` opt along with the manager module, wrapped in a tuple.

  ## Examples

  ```elixir
  # standard path: lib/my_app/manager.ex
  config :ecsx, manager: MyApp.Manager

  # custom path: lib/foo/bar/baz.ex
  config :ecsx, manager: {MyApp.Manager, path: "lib/foo/bar/baz.ex"}
  ```
  """
  @spec manager_path() :: binary() | nil
  def manager_path do
    case Application.get_env(:ecsx, :manager) do
      {_module, path: path} when is_binary(path) ->
        path

      nil ->
        nil

      module when is_atom(module) ->
        path =
          module
          |> Module.split()
          |> Enum.map_join("/", &Macro.underscore/1)

        "lib/" <> path <> ".ex"
    end
  end

  @doc """
  Returns the tick rate of the ECSx application.

  This defaults to 20, and can be changed in your app configuration:

  ```elixir
  config :ecsx, tick_rate: 15
  ```
  """
  @spec tick_rate() :: integer()
  def tick_rate do
    Application.get_env(:ecsx, :tick_rate, 20)
  end
end
