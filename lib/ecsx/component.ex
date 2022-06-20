defmodule ECSx.Component do
  @moduledoc """
  A Component labels an entity as possessing a particular aspect, and holds the data
  needed to model that aspect. Under the hood, we use ETS to store the Components
  in memory for quick retrieval via aspect and entity ID.
  """

  def mapify(object, fields) do
    values = Tuple.to_list(object)

    fields
    |> Enum.zip(values)
    |> Map.new()
  end

  def parse_field(object, fields, selected_field) do
    index = Enum.find_index(fields, &(&1 == selected_field))

    elem(object, index)
  end
end
