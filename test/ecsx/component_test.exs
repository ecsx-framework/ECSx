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

  describe "#query_one/3" do
    setup :setup_set

    test "when component exists" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})

      component = Component.query_one(:sample_aspect, @sample_fields, match: [id: 123])

      assert component == %{id: 123, foo: "test", bar: "sample"}
    end

    test "when component does not exist" do
      assert Component.query_one(:sample_aspect, @sample_fields, match: [id: 123]) == nil
    end

    test "with value query" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})

      foo = Component.query_one(:sample_aspect, @sample_fields, match: [id: 123], value: :foo)
      bar = Component.query_one(:sample_aspect, @sample_fields, match: [id: 123], value: :bar)

      assert foo == "test"
      assert bar == "sample"
    end

    test "value query ignored when no results are found" do
      foo = Component.query_one(:sample_aspect, @sample_fields, match: [id: 456], value: :foo)
      bar = Component.query_one(:sample_aspect, @sample_fields, match: [id: 456], value: :bar)

      assert foo == nil
      assert bar == nil
    end

    test "raises if multiple results are found" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {456, "test", "dos"})

      message = """
      query_one expects zero or one results, got 2 from query:

      [foo: \"test\"]
      """

      assert_raise ECSx.QueryError, message, fn ->
        Component.query_one(:sample_aspect, @sample_fields, match: [foo: "test"])
      end
    end
  end

  describe "#get_many/3" do
    setup :setup_bag

    test "when components exist" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {123, "numero", "dos"})

      assert Component.query_all(:sample_aspect, @sample_fields, match: [id: 123]) == [
               %{id: 123, foo: "test", bar: "sample"},
               %{id: 123, foo: "numero", bar: "dos"}
             ]
    end

    test "for zero components" do
      assert Component.query_all(:sample_aspect, @sample_fields, match: [id: 123]) == []
    end

    test "with value query" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {123, "numero", "dos"})

      foos = Component.query_all(:sample_aspect, @sample_fields, match: [id: 123], value: :foo)
      bars = Component.query_all(:sample_aspect, @sample_fields, match: [id: 123], value: :bar)

      assert foos == ["test", "numero"]
      assert bars == ["sample", "dos"]
    end

    test "value query ignored when no results are found" do
      foos = Component.query_all(:sample_aspect, @sample_fields, match: [id: 456], value: :foo)
      bars = Component.query_all(:sample_aspect, @sample_fields, match: [id: 456], value: :bar)

      assert foos == []
      assert bars == []
    end

    test "no query returns all components" do
      :ets.insert(:sample_aspect, {123, "test", "sample"})
      :ets.insert(:sample_aspect, {456, "numero", "dos"})

      components = Component.query_all(:sample_aspect, @sample_fields, [])

      assert components == [
               %{id: 456, foo: "numero", bar: "dos"},
               %{id: 123, foo: "test", bar: "sample"}
             ]
    end

    test "no query on an empty table" do
      assert Component.query_all(:sample_aspect, @sample_fields, []) == []
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
