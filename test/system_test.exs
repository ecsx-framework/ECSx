defmodule ECSx.SystemTest do
  use ExUnit.Case

  alias ECSx.Test.Couple

  defmodule Incrementer do
    use ECSx.System

    @impl ECSx.System
    def run do
      couples = Couple.get_all()

      Enum.each(couples, fn %{id: id, foo: foo} ->
        Couple.remove(id)
        Couple.add(id: id, foo: foo + 1)
      end)
    end
  end

  setup do
    Couple.init()
    Couple.add(id: 1, foo: 1)
    Couple.add(id: 100, foo: 100)
  end

  describe "Incrementer system" do
    test "#run/0" do
      Incrementer.run()

      assert :ets.lookup(Couple, 1) == [{1, 2}]
      assert :ets.lookup(Couple, 100) == [{100, 101}]

      Incrementer.run()

      assert :ets.lookup(Couple, 1) == [{1, 3}]
      assert :ets.lookup(Couple, 100) == [{100, 102}]
    end
  end
end
