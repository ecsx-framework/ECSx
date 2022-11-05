defmodule ECSx.Tag do
  @moduledoc """
  A component which does not require a value.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.Tag

      # TODO: what if table_type is invalid?
      @table_type opts[:table_type] || :set
      @table_name opts[:table_name] || __MODULE__
      @concurrency {:read_concurrency, opts[:read_concurrency] || false}

      def init, do: ECSx.Base.init(@table_name, @table_type, @concurrency)

      def add(entity_id), do: ECSx.Base.add(@table_name, {entity_id})

      def remove(entity_id), do: ECSx.Base.remove(@table_name, entity_id)

      def exists?(entity_id), do: ECSx.Base.exists?(@table_name, entity_id)
    end
  end

  @doc """
  Creates a new tag for a given entity.
  """
  @callback add(entity_id :: any) :: :ok

  @doc """
  Removes this component from an entity.
  """
  @callback remove(entity_id :: any) :: :ok

  @doc """
  Checks if an entity has this tag.
  """
  @callback exists?(entity_id :: any) :: boolean
end
