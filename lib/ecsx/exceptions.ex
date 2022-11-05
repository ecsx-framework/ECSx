defmodule ECSx.QueryError do
  @moduledoc """
  Raised at runtime when the Query is invalid.
  """
  defexception [:message]

  def exception(opts) do
    message = Keyword.fetch!(opts, :message)
    entity_id = Keyword.fetch!(opts, :entity_id)

    message = """
    #{message} from entity ID #{inspect(entity_id)}
    """

    %__MODULE__{message: message}
  end
end
