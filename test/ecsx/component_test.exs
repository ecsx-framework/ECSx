defmodule ECSx.ComponentTest do
  use ExUnit.Case

  alias ECSx.Component

  @sample_fields [:id, :foo, :bar]

  describe "#add/3" do
    setup :setup_set

    test "successful when all fields present" do
      Component.add(:sample_aspect, [id: 123, foo: "test", bar: "sample"], @sample_fields)

      assert :ets.lookup(:sample_aspect, 123) == [{123, "test", "sample"}]
    end

    test "raises when missing fields" do
      assert_raise KeyError, "key :foo not found in: [id: 123, bar: \"sample\"]", fn ->
        Component.add(:sample_aspect, [id: 123, bar: "sample"], @sample_fields)
      end
    end

    test "ignores extra fields" do
      attrs = [id: 123, foo: "test", bar: "sample", extra: :ignored, invalid: 000]
      Component.add(:sample_aspect, attrs, @sample_fields)

      assert :ets.lookup(:sample_aspect, 123) == [{123, "test", "sample"}]
    end
  end

  describe "#get_one/3" do
    setup :setup_set

    test "when component exists" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})

      component = Component.get_one(:sample_aspect, 123, @sample_fields)

      assert component == %{id: 123, foo: "test", bar: "sample"}
    end

    test "when component does not exist" do
      assert Component.get_one(:sample_aspect, 123, @sample_fields) == nil
    end
  end

  describe "#get_many/3" do
    setup :setup_bag

    test "when components exist" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {123, "numero", "dos"})

      assert Component.get_many(:sample_aspect, 123, @sample_fields) == [
               %{id: 123, foo: "test", bar: "sample"},
               %{id: 123, foo: "numero", bar: "dos"}
             ]
    end

    test "for zero components" do
      assert Component.get_many(:sample_aspect, 456, @sample_fields) == []
    end
  end

  describe "#get_value/4" do
    setup :setup_set

    test "when component exists" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})

      assert Component.get_value(:sample_aspect, 123, :foo, @sample_fields) == "test"
      assert Component.get_value(:sample_aspect, 123, :bar, @sample_fields) == "sample"
    end

    test "for zero components" do
      assert Component.get_value(:sample_aspect, 456, :foo, @sample_fields) == nil
    end
  end

  describe "#get_values/4" do
    setup :setup_bag

    test "when components exist" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {123, "numero", "dos"})

      assert Component.get_values(:sample_aspect, 123, :foo, @sample_fields) == ["test", "numero"]
      assert Component.get_values(:sample_aspect, 123, :bar, @sample_fields) == ["sample", "dos"]
    end

    test "for zero components" do
      assert Component.get_values(:sample_aspect, 456, :foo, @sample_fields) == []
    end
  end

  describe "#get_all/2" do
    setup :setup_set

    test "when components exist" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {456, "numero", "dos"})

      components = Component.get_all(:sample_aspect, @sample_fields)

      assert components == [
               %{id: 456, foo: "numero", bar: "dos"},
               %{id: 123, foo: "test", bar: "sample"}
             ]
    end

    test "for zero components" do
      assert Component.get_all(:sample_aspect, @sample_fields) == []
    end
  end

  describe "#remove/2" do
    test "one component from set table" do
      setup_set([])

      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {456, "numero", "dos"})

      Component.remove(:sample_aspect, 123)

      assert :ets.tab2list(:sample_aspect) == [{456, "numero", "dos"}]
      refute :ets.lookup(:sample_aspect, 123) == [{123, "test", "sample"}]
    end

    test "multiple components from bag table" do
      setup_bag([])

      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {123, "numero", "dos"})

      Component.remove(:sample_aspect, 123)

      assert :ets.lookup(:sample_aspect, 123) == []
    end
  end

  describe "#exists?/2" do
    setup :setup_set

    test "test" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})

      assert Component.exists?(:sample_aspect, 123)
      refute Component.exists?(:sample_aspect, 456)
    end
  end

  defp setup_set(_) do
    :ets.new(:sample_aspect, [:named_table])
    :ok
  end

  defp setup_bag(_) do
    :ets.new(:sample_aspect, [:named_table, :bag])
    :ok
  end
end
