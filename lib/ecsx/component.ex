defmodule ECSx.Component do
  @moduledoc """
  A Component labels an entity as possessing a particular aspect, and holds the data
  needed to model that aspect. Under the hood, we use ETS to store the Components
  in memory for quick retrieval via aspect and entity ID.
  """

  def add(aspect, attrs, fields) do
    row =
      fields
      |> Enum.map(&Keyword.fetch!(attrs, &1))
      |> List.to_tuple()

    :ets.insert(aspect, row)
    :ok
  end

  def get_one(aspect, entity_id, fields) do
    case :ets.lookup(aspect, entity_id) do
      [] -> nil
      [object] -> mapify(object, fields)
    end
  end

  def get_many(aspect, entity_id, fields) do
    aspect
    |> :ets.lookup(entity_id)
    |> Enum.map(&mapify(&1, fields))
  end

  def get_value(aspect, entity_id, selected_field, fields) do
    case :ets.lookup(aspect, entity_id) do
      [] -> nil
      [object] -> parse_field(object, fields, selected_field)
    end
  end

  def get_values(aspect, entity_id, selected_field, fields) do
    aspect
    |> :ets.lookup(entity_id)
    |> Enum.map(&parse_field(&1, fields, selected_field))
  end

  def get_all(aspect, fields) do
    aspect
    |> :ets.tab2list()
    |> Enum.map(&mapify(&1, fields))
  end

  def remove(aspect, entity_id) do
    :ets.delete(aspect, entity_id)
    :ok
  end

  def exists?(aspect, entity_id) do
    :ets.member(aspect, entity_id)
  end

  defp mapify(object, fields) do
    values = Tuple.to_list(object)

    fields
    |> Enum.zip(values)
    |> Map.new()
  end

  defp parse_field(object, fields, selected_field) do
    index = Enum.find_index(fields, &(&1 == selected_field))

    elem(object, index)
  end
end
