Application.put_env(:ecsx, :persistence_adapter, ECSx.Persistence.MockPersistenceAdapter)
ExUnit.start()
