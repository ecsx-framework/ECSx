defmodule ECSx.Factory do
  alias ECSx.KVTestComponent

  def initialize_table(module) do
    module.__init__()
  end

  def insert_new(module) do
    attrs = build_new(module)

    module.add(attrs)

    Map.new(attrs)
  end

  def build_new(KVTestComponent) do
    [id: Enum.random(1..99999), name: name()]
  end

  defp name do
    1..6
    |> Enum.map(fn _ -> Enum.random(97..122) end)
    |> List.to_string()
  end
end
