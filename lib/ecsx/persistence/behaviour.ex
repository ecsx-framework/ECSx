defmodule ECSx.Persistence.Behaviour do
  @moduledoc """
  By default, ECSx persists component data by writing a binary file to disk, then reading the file
  when the server restarts.  If you would like to use a different method, you can create a module
  which implements this behaviour, and update the ECSx configuration to use your module instead of
  the default.

  ## `persist_components/2` and `retrieve_components/1`

  To create your own persistence adapter, you only need to implement two functions:

    * `persist_components/2` - This function takes a list of tuples, where each tuple is of the form
      `{component_type, list_of_components}`.  A keyword list of options is also be passed as a
      second argument.  The function should store the data, then return `:ok`.
    * `retrieve_components/1` - This function takes a list of options, and should return
      `{:ok, list_of_tuples}` where each tuple in `list_of_tuples` is of the form
      `{component_type, list_of_components}`.

  ## Configuring ECSx to use a custom persistence adapter

  Once you have created a persistence adapter module, simply update your application config to use it:

      config :ecsx,
        ...
        persistence_adapter: MyAdapterModule

  """

  @type components :: list({module(), list(tuple())})
  @callback persist_components(components :: components(), opts :: keyword()) :: :ok
  @callback retrieve_components(opts :: keyword()) ::
              {:ok, components()} | {:error, :fresh_server | any()}
end
