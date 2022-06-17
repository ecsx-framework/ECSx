defmodule ECSx.Factory do
  alias ECSx.Component
  alias ECSx.Test.Couple
  alias ECSx.Test.Triple

  def insert_new(module) do
    attrs = build_new(module)

    Component.add(module, attrs)

    Map.new(attrs)
  end

  def build_new(Couple), do: [id: Enum.random(1..99999), foo: random_string()]

  def build_new(Triple),
    do: [id: Enum.random(1..99999), foo: random_string(), bar: random_string()]

  defp random_string do
    1..6
    |> Enum.map(fn _ -> Enum.random(97..122) end)
    |> List.to_string()
  end
end
