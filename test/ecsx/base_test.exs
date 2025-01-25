defmodule ECSx.BaseTest do
  use ExUnit.Case

  alias ECSx.Base

  setup do
    table_name = :sample_component
    :ets.new(table_name, [:named_table])

    index_table = Module.concat(table_name, "Index")
    :ets.new(index_table, [:named_table, :bag])

    :ok
  end

  describe "#add/4" do
    test "successful" do
      Base.add(:sample_component, 123, "test", [])

      assert :ets.lookup(:sample_component, 123) == [{123, "test", false}]
    end

    test "raises when already exists" do
      :ets.insert(:sample_component, {123, "test", false})

      assert_raise ECSx.AlreadyExistsError,
                   "`add` expects component to not exist yet from entity 123\n",
                   fn ->
                     Base.add(:sample_component, 123, "test", [])
                   end
    end

    test "with index" do
      assert :ok == Base.add(:sample_component, 123, "test", index: true)

      index_table = Module.concat(:sample_component, "Index")

      assert :ets.tab2list(index_table) == [{"test", 123, false}]
    end
  end

  describe "#update/4" do
    test "successful" do
      :ets.insert(:sample_component, {123, "test", false})
      Base.update(:sample_component, 123, "test2", [])
      assert [{123, "test2", false}] == :ets.tab2list(:sample_component)
    end

    test "raises when doesn't exist" do
      assert_raise ECSx.NoResultsError,
                   "`update` expects an existing value from entity 123\n",
                   fn ->
                     Base.update(:sample_component, 123, "test2", [])
                   end
    end

    test "with index" do
      :ets.insert(:sample_component, {123, "test", false})
      index_table = Module.concat(:sample_component, "Index")
      :ets.insert(index_table, {"test", 123, false})

      assert :ok == Base.update(:sample_component, 123, "test2", index: true)
      assert :ets.tab2list(index_table) == [{"test2", 123, false}]
    end
  end

  describe "#get/2" do
    test "when component exists" do
      :ets.insert(:sample_component, {123, "shazam"})

      assert Base.get(:sample_component, 123, []) == "shazam"
    end

    test "returns default when component does not exist" do
      assert Base.get(:sample_component, 123, :some_val) == :some_val
    end

    test "raises when component does not exist" do
      assert_raise ECSx.NoResultsError,
                   "`get` expects one result, got 0 from entity 123\n",
                   fn -> Base.get(:sample_component, 123, :raise) end
    end
  end

  describe "#get_all/1" do
    test "when components exist" do
      :ets.insert(:sample_component, {123, "foo"})
      :ets.insert(:sample_component, {456, "bar"})

      assert Base.get_all(:sample_component) |> Enum.sort() == [{123, "foo"}, {456, "bar"}]
    end

    test "for zero components" do
      assert Base.get_all(:sample_component) == []
    end
  end

  describe "#between/3" do
    test "integers" do
      :ets.insert(:sample_component, {123, 1, false})
      :ets.insert(:sample_component, {234, 2, false})
      :ets.insert(:sample_component, {345, 3, true})

      assert :sample_component
             |> Base.between(2, 3)
             |> Enum.sort() == [{234, 2}, {345, 3}]
    end
  end

  describe "#at_least/2" do
    test "integers" do
      :ets.insert(:sample_component, {123, 1, true})
      :ets.insert(:sample_component, {234, 2, true})
      :ets.insert(:sample_component, {345, 3, false})

      assert :sample_component
             |> Base.at_least(2)
             |> Enum.sort() == [{234, 2}, {345, 3}]
    end
  end

  describe "#at_most/2" do
    test "integers" do
      :ets.insert(:sample_component, {123, 1, true})
      :ets.insert(:sample_component, {234, 2, true})
      :ets.insert(:sample_component, {345, 3, true})

      assert :sample_component
             |> Base.at_most(2)
             |> Enum.sort() == [{123, 1}, {234, 2}]
    end
  end

  describe "#remove/2" do
    test "test" do
      :ets.insert(:sample_component, {123, "uno", false})
      :ets.insert(:sample_component, {456, "dos", false})

      Base.remove(:sample_component, 123, [])

      assert :ets.lookup(:sample_component, 123) == []
      assert :ets.lookup(:sample_component, 456) == [{456, "dos", false}]
    end

    test "with index" do
      index_table = Module.concat(:sample_component, "Index")

      :ets.insert(:sample_component, {123, "uno", false})
      :ets.insert(index_table, {"uno", 123, false})

      :ets.insert(:sample_component, {456, "dos", false})
      :ets.insert(index_table, {"dos", 456, false})

      Base.remove(:sample_component, 123, index: true)

      assert :ets.tab2list(index_table) == [{"dos", 456, false}]
    end
  end

  describe "#exists?/2" do
    test "test" do
      :ets.insert(:sample_component, {123, "test", false})

      assert Base.exists?(:sample_component, 123)
      refute Base.exists?(:sample_component, 456)
    end
  end
end
