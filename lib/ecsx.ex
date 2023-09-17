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

  ## Configuration

  You may configure various settings for ECSx in the application environment
  (usually defined in `config/config.exs`):

      config :ecsx,
        manager: MyApp.Manager,
        tick_rate: 20,
        persist_interval: :timer.seconds(15),
        persistence_adapter: ECSx.Persistence.FileAdapter,
        persistence_file_location: "components.persistence"

    * `:manager` - This setting defines the module and path for your app's ECSx Manager.
      When only a module name is given here, the path will be inferred using the standard
      directory conventions (e.g. `MyApp.Manager` becomes `lib/my_app/manager.ex`).
      If you are using a different structure for your directories, you can instead use a tuple
      including the `:path` option (e.g. `{ManagerModule, path: "lib/path/to/file.ex"}`)
    * `:tick_rate` - This controls how many times per second each system will run.  Setting a higher
      value here can make a smoother experience for users of your app, but will come at the cost
      of increased server load.  Increasing this value beyond your hardware's capabilities will
      result in instability across the entire application, worsening over time until eventually
      the application crashes.
    * `:persist_interval` - ECSx makes regular backups of all components marked for persistence.
      This setting defines the length of time between each backup.
    * `:persistence_adapter` - If you have a custom adapter which implements
      `ECSx.Persistence.Behaviour`, you can set it here to replace the default `FileAdapter`.
    * `:persistence_file_location` - If you are using the default `FileAdapter` for persistence,
      this setting allows you to define the path for the backup file.

  """
  use Application

  @doc false
  def start(_type, _args) do
    children = [ECSx.ClientEvents, ECSx.Persistence.Server] ++ List.wrap(ECSx.manager() || [])

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

  @doc """
  Returns the frequency of component persistence.

  This defaults to 15 seconds, and can be changed in your app configuration:

  ```elixir
  config :ecsx, persist_interval: :timer.minutes(1)
  ```
  """
  @spec persist_interval() :: integer()
  def persist_interval do
    Application.get_env(:ecsx, :persist_interval, :timer.seconds(15))
  end
end
