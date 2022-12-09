defmodule ECSx.BaseTest do
  use ExUnit.Case

  alias ECSx.Base

  describe "#add/2" do
    setup :setup_component

    test "successful" do
      Base.add(:sample_component, {123, "test"})

      assert :ets.lookup(:sample_component, 123) == [{123, "test"}]
    end
  end

  describe "#get_one/2" do
    setup [:setup_component, :setup_nonunique_component]

    test "when component exists" do
      :ets.insert(:sample_component, {123, "shazam"})

      assert Base.get_one(:sample_component, 123) == "shazam"
    end

    test "when component does not exist" do
      assert Base.get_one(:sample_component, 123) == nil
    end

    test "raises if multiple results are found" do
      :ets.insert(:nonunique_component, {123, "uno"})
      :ets.insert(:nonunique_component, {123, "dos"})

      message = "get_one expects zero or one results, got 2 from entity ID 123\n"

      assert_raise ECSx.QueryError, message, fn ->
        Base.get_one(:nonunique_component, 123)
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
      :ets.insert(:sample_component, {123, "uno"})
      :ets.insert(:sample_component, {456, "dos"})

      Base.remove(:sample_component, 123)

      assert :ets.lookup(:sample_component, 123) == []
      assert :ets.lookup(:sample_component, 456) == [{456, "dos"}]
    end

    test "multiple components from nonunique type" do
      :ets.insert(:nonunique_component, {123, "uno"})
      :ets.insert(:nonunique_component, {123, "dos"})
      :ets.insert(:nonunique_component, {456, "tres"})

      Base.remove(:nonunique_component, 123)

      assert :ets.lookup(:nonunique_component, 123) == []
      assert :ets.lookup(:nonunique_component, 456) == [{456, "tres"}]
    end
  end

  describe "#remove_one/3" do
    setup :setup_nonunique_component

    test "removes one of several components" do
      :ets.insert(:nonunique_component, {123, "uno"})
      :ets.insert(:nonunique_component, {123, "dos"})

      Base.remove_one(:nonunique_component, 123, "uno")

      assert :ets.lookup(:nonunique_component, 123) == [{123, "dos"}]
    end
  end

  describe "#exists?/2" do
    setup :setup_component

    test "test" do
      :ets.insert(:sample_component, {123, "test"})

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
