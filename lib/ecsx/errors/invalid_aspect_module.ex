defmodule ECSx.InvalidAspectModule do
  defexception [:message]

  @impl true
  def exception(term) do
    msg = "#{inspect(term)} does not use ECSx.Component"
    %__MODULE__{message: msg}
  end
end
