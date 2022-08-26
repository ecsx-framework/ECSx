defmodule ECSx.Component do
  @moduledoc false

  # A Component labels an entity as possessing a particular aspect, and holds the data
  # needed to model that aspect. Under the hood, we use ETS to store the Components
  # in memory for quick retrieval via aspect and entity ID.

  @type t :: map
  @type value :: any

  def add(aspect, attrs, fields) do
    row =
      fields
      |> Enum.map(&Keyword.fetch!(attrs, &1))
      |> List.to_tuple()

    :ets.insert(aspect, row)
    :ok
  end

  def query_all(aspect, fields, []) do
    aspect
    |> :ets.tab2list()
    |> Enum.map(&mapify(&1, fields))
  end

  def query_all(aspect, fields, queries) do
    matches = Keyword.fetch!(queries, :match)
    pattern = make_pattern(fields, matches)

    results = :ets.match_object(aspect, pattern)

    parse_results(results, queries, fields)
  end

  def query_one(aspect, fields, queries) do
    matches = Keyword.fetch!(queries, :match)
    pattern = make_pattern(fields, matches)

    case :ets.match_object(aspect, pattern) do
      [] -> nil
      [result] -> parse_one(result, queries, fields)
      results -> query_error(results, matches)
    end
  end

  defp make_pattern(fields, matches) do
    fields
    |> Enum.map(&Keyword.get(matches, &1, :_))
    |> List.to_tuple()
  end

  defp parse_results(results, queries, fields) when is_list(results) do
    case Keyword.get(queries, :value, nil) do
      nil -> Enum.map(results, &mapify(&1, fields))
      field -> Enum.map(results, &parse_field(&1, fields, field))
    end
  end

  defp parse_one(result, queries, fields) do
    [parsed_result] = parse_results([result], queries, fields)
    parsed_result
  end

  def query_error(results, matches) do
    raise ECSx.QueryError,
      message: "query_one expects zero or one results, got #{length(results)}",
      matches: matches
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
