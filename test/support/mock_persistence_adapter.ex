defmodule ECSx.Persistence.MockPersistenceAdapter do
  @behaviour ECSx.Persistence.Behaviour

  def retrieve_components(opts \\ []) do
    {:ok, Keyword.get(opts, :test_components, [])}
  end

  def persist_components(components, opts) do
    target = Keyword.fetch!(opts, :target)
    send(target, {:persist_components, components})
  end
end
