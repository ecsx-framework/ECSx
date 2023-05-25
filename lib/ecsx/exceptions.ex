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

defmodule ECSx.ValueComparisonError do
  defexception [:message]

  def exception(opts) do
    fn_name = Keyword.fetch!(opts, :fn_name)
    component_type = Keyword.fetch!(opts, :component_type)
    value_type = Keyword.fetch!(opts, :value_type)

    message = """
    `#{fn_name}` is only valid for components with integer or float values
    #{inspect(component_type)} is configured as `value: #{inspect(value_type)}`
    """

    %__MODULE__{message: message}
  end
end
