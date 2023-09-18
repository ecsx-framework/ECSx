# Common Caveats

The ECSx API has been carefully designed to avoid common Elixir pitfalls and encourage efficient architectural patterns in your application.  However, there are still some opportunities for bad patterns to sneak in and destabilize performance.  This guide will list known problems and how to avoid them.

## Database Queries

It is expected that most applications will use a database at some point or another.  However, when dealing with `ECSx.System`s, which run many times per second, most databases are too slow to keep up as the load grows.  Each server tick has a deadline to finish its work, and if it falls behind, there will be lag, unstable performance, and eventually game crashes.

> #### Therefore: {: .error}
>
> You should never query the database from within a system

Instead:  use `ECSx.Manager.setup/1` to read the necessary data from the database at startup, and create components with it.  Components are stored in memory, allowing the quick reads and writes which are required for system logic.

Example:

```elixir
defmodule MyApp.Manager do
  use ECSx.Manager

  alias MyApp.Components.Height
  alias MyApp.Components.XPosition
  alias MyApp.Components.YPosition
  alias MyApp.Trees
  alias MyApp.Trees.Tree

  setup do
    for %Tree{id: id, x: x, y: y, height: height} <- Trees.my_db_query() do
        XPosition.add(id, x)
        YPosition.add(id, y)
        Height.add(id, height)
    end
  end
  ...
end
```

Then when our systems need to work with the height or position of trees, we use the `ECSx.Component` API instead of querying the database again.

## External Requests

Database queries are just one example of a slow call which can hold up the game systems.  Any other request to a service outside your application will likely be too slow to be used in system logic.

Instead:

  * If you only need to make the request once upon initialization, use `ECSx.Manager.setup/1` as shown above
  * If the request is made once, but triggered by input to some client process, that process should make the request (or spawn a `Task` for it)
  * If the request should happen regularly, create a new [`GenServer`](https://hexdocs.pm/elixir/GenServer.html#module-receiving-regular-messages) (don't forget to add it to your app's supervision tree)
  * If you have more than one external request happening regularly, this is a good use case for the [`Oban`](https://hexdocs.pm/oban/Oban.html) library
  * Remember that client processes (including GenServers, LiveViews, and Oban) have read-only access
  to components, and must use `ECSx.ClientEvents` for writes

  ## search/1 Without Index

  `ECSx.Component.search/1` will scan all Components of the given type to find matches.  This can be
  OK if the quantity of Components of that type is small, or if it is just a one-time search.  But
  if you are searching every tick within a System, through a large list of Components, this can become
  a performance concern.  The solution is to set the `index: true` option, which will drastically
  improve search performance.
