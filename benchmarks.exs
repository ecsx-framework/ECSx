alias ECSx.SampleComponent

SampleComponent.initialize_table()
Enum.each(1..100, &SampleComponent.add(&1, "name-#{&1}"))

Benchee.run(%{
  "map" => fn -> Enum.each(1..100, &SampleComponent.get_full/1) end,
  "tuple" => fn -> Enum.each(1..100, &SampleComponent.get_raw/1) end,
  "value" => fn -> Enum.each(1..100, &SampleComponent.get_value/1) end
})
