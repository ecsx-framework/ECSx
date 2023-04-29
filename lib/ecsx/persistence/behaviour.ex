defmodule ECSx.Persistence.Behaviour do
  @type components :: list({module(), list(tuple())})
  @callback persist_components(components :: components(), opts :: keyword()) :: :ok
  @callback retrieve_components(opts :: keyword()) ::
              {:ok, components()} | {:error, :fresh_server | any()}
end
