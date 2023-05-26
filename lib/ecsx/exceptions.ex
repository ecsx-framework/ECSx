defmodule ECSx.MultipleResultsError do
  defexception [:message]

  def exception(opts) do
    message = Keyword.fetch!(opts, :message)
    entity_id = Keyword.fetch!(opts, :entity_id)

    message = """
    #{message} from entity #{entity_id}
    """

    %__MODULE__{message: message}
  end
end

defmodule ECSx.NoResultsError do
  defexception [:message]

  def exception(opts) do
    message = Keyword.fetch!(opts, :message)
    entity_id = Keyword.fetch!(opts, :entity_id)

    message = """
    #{message} from entity #{entity_id}
    """

    %__MODULE__{message: message}
  end
end

defmodule ECSx.AlreadyExistsError do
  defexception [:message]

  def exception(opts) do
    message = Keyword.fetch!(opts, :message)
    entity_id = Keyword.fetch!(opts, :entity_id)

    message = """
    #{message} from entity #{entity_id}
    """

    %__MODULE__{message: message}
  end
end
