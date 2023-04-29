defmodule ECSx.Persistence.FileAdapter do
  @behaviour ECSx.Persistence.Behaviour

  @default_file_location "components.persistence"

  @impl ECSx.Persistence.Behaviour
  def persist_components(components, _opts \\ []) do
    bytes = :erlang.term_to_binary(components)
    File.write!(file_location(), bytes)
  end

  @impl ECSx.Persistence.Behaviour
  def retrieve_components(_opts \\ []) do
    file_location = file_location()

    with true <- File.exists?(file_location),
         {:ok, binary} <- File.read(file_location),
         component_map <- :erlang.binary_to_term(binary) do
      {:ok, component_map}
    else
      false -> {:error, :fresh_server}
      {:error, reason} -> {:error, reason}
    end
  rescue
    e -> {:error, e}
  end

  defp file_location do
    Application.get_env(:ecsx, :persistence_file_location, @default_file_location)
  end
end
