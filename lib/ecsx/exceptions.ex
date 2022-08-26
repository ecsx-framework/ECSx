defmodule ECSx.QueryError do
  @moduledoc """
  Raised at runtime when the query is invalid.
  """
  defexception [:message]

  def exception(opts) do
    message = Keyword.fetch!(opts, :message)
    query = Keyword.fetch!(opts, :matches)

    message = """
    #{message} from query:

    #{inspect(query)}
    """

    %__MODULE__{message: message}
  end
end
