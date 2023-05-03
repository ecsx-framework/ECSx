defmodule ECSx.BaseTest do
  use ExUnit.Case

  alias ECSx.Base

  describe "#add/4" do
    setup :setup_nonunique_component

    test "successful" do
      assert :ok == Base.add(:nonunique_component, 123, "test", [])
      assert :ok == Base.add(:nonunique_component, 123, "test2", [])
      assert :ok == Base.add(:nonunique_component, 123, "test2", [])

      assert :ets.lookup(:nonunique_component, 123) == [
               {123, "test", false},
               {123, "test2", false}
             ]
    end
  end

  describe "#add_new/4" do
    setup :setup_component

    test "successful" do
      Base.add_new(:sample_component, 123, "test", [])

      assert :ets.lookup(:sample_component, 123) == [{123, "test", false}]
    end

    test "raises when already exists" do
      :ets.insert(:sample_component, {123, "test", false})

      assert_raise ECSx.AlreadyExistsError,
                   "`add` expects component to not exist yet from entity 123\n",
                   fn ->
                     Base.add_new(:sample_component, 123, "test", [])
                   end
    end
  end

  describe "#update/4" do
    setup :setup_component

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
  end

  describe "#get_one/2" do
    setup [:setup_component, :setup_nonunique_component]

    test "when component exists" do
      :ets.insert(:sample_component, {123, "shazam"})

      assert Base.get_one(:sample_component, 123, []) == "shazam"
    end

    test "returns default when component does not exist" do
      assert Base.get_one(:sample_component, 123, :some_val) == :some_val
    end

    test "raises when component does not exist" do
      assert_raise ECSx.NoResultsError,
                   "`get_one` expects one result, got 0 from entity 123\n",
                   fn -> Base.get_one(:sample_component, 123, :raise) end
    end

    test "raises if multiple results are found" do
      :ets.insert(:nonunique_component, {123, "uno"})
      :ets.insert(:nonunique_component, {123, "dos"})

      message = "`get_one` expects one result, got 2 from entity 123\n"

      assert_raise ECSx.MultipleResultsError, message, fn ->
        Base.get_one(:nonunique_component, 123, [])
      end
    end
  end

  describe "#get_all/1" do
    setup :setup_component

    test "when components exist" do
      :ets.insert(:sample_component, {123, "foo"})
      :ets.insert(:sample_component, {456, "bar"})

      assert Base.get_all(:sample_component) |> Enum.sort() == [{123, "foo"}, {456, "bar"}]
    end

    test "for zero components" do
      assert Base.get_all(:sample_component) == []
    end
  end

  describe "#get_all/2" do
    setup :setup_nonunique_component

    test "when components exist" do
      :ets.insert(:nonunique_component, {123, "A"})
      :ets.insert(:nonunique_component, {123, "B"})

      assert Base.get_all(:nonunique_component, 123) == ["A", "B"]
    end

    test "for zero components" do
      assert Base.get_all(:nonunique_component, 123) == []
    end
  end

  describe "#remove/2" do
    setup [:setup_component, :setup_nonunique_component]

    test "one component from unique type" do
      :ets.insert(:sample_component, {123, "uno", false})
      :ets.insert(:sample_component, {456, "dos", false})

      Base.remove(:sample_component, 123, [])

      assert :ets.lookup(:sample_component, 123) == []
      assert :ets.lookup(:sample_component, 456) == [{456, "dos", false}]
    end

    test "multiple components from nonunique type" do
      :ets.insert(:nonunique_component, {123, "uno", false})
      :ets.insert(:nonunique_component, {123, "dos", false})
      :ets.insert(:nonunique_component, {456, "tres", false})

      Base.remove(:nonunique_component, 123, [])

      assert :ets.lookup(:nonunique_component, 123) == []
      assert :ets.lookup(:nonunique_component, 456) == [{456, "tres", false}]
    end
  end

  describe "#remove_one/3" do
    setup :setup_nonunique_component

    test "removes one of several components" do
      :ets.insert(:nonunique_component, {123, "uno", false})
      :ets.insert(:nonunique_component, {123, "dos", false})

      Base.remove_one(:nonunique_component, 123, "uno", [])

      assert :ets.lookup(:nonunique_component, 123) == [{123, "dos", false}]
    end

    test "raises when doesn't exist" do
      assert_raise ECSx.NoResultsError,
                   "no value found for {123, \"uno\"} from entity 123\n",
                   fn ->
                     Base.remove_one(:nonunique_component, 123, "uno", [])
                   end
    end
  end

  describe "#exists?/2" do
    setup :setup_component

    test "test" do
      :ets.insert(:sample_component, {123, "test", false})

      assert Base.exists?(:sample_component, 123)
      refute Base.exists?(:sample_component, 456)
    end
  end

  defp setup_component(_) do
    :ets.new(:sample_component, [:named_table])
    :ok
  end

  defp setup_nonunique_component(_) do
    :ets.new(:nonunique_component, [:named_table, :bag])
    :ok
  end
end
