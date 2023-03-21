defmodule ECSx.Constant do
  @moduledoc """
  Constants are components which never change, and are shared among all entities.

  Commonly, you will want to add a component where the value is deterministic, based on the value of other components.  For example, you might have a game where the player wears armor to reduce damage from incoming attacks, but the quantity of reduction is based on the material of which the armor is made.  Instead of introducing a new ItemArmorRating component to store that value, we'll define ItemArmorRating as a Constant.

  The values are set at compile time by passing a Map:

  ```
  defmodule ItemArmorRating do
    use ECSx.Constant,
      values: %{
        wood: 5,
        iron: 10,
        gold: 15,
        diamond: 20
      }
  end
  ```

  Then you can get the value you need by calling

  ```
  ItemArmorRating.get(:iron)
  10
  ```

  Using Constants, where possible, will improve performance and reduce complexity as your app grows.

  > Note: Constants should NOT be added to the list of components in your manager file.

  ## Nested maps

  You might find some constants which benefit from being stored as a tree.  For example, let's say there are multiple armor "slots" such as helmet, shield, boots, breastplate, etc, and each one of these can be made of different materials.  We'll use nested maps to set these values:

  ```
  defmodule ItemArmorRating do
    use ECSx.Constant,
      values: %{
        helmet: %{
          wood: 1,
          iron: 2,
          gold: 3,
          diamond: 4
        },
        shield: %{
          wood: 5,
          iron: 8,
          gold: 12,
          diamond: 20
        },
        ...
      }
  end
  ```

  Then we can pass the appropriate keys as a list to `get/1`:

  ```
  ItemArmorRating.get([:shield, :gold])
  12
  ```

  ## Key types

  For best performance, it is advised to avoid string keys, and prefer either atoms, or integers.
  """

  @type key() :: any()

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ECSx.Constant

      @values Keyword.get(opts, :values, %{})

      def get(key_path) when is_list(key_path) do
        get_in(@values, key_path)
      end

      def get(key) do
        @values[key]
      end
    end
  end

  @doc """
  Gets the value for a given key (or key path for nested value maps).

  ## Examples

      # Simple categories (small, medium, or large)
      SizeFactor.get(:large)

      # Nested data (race -> class -> level)
      MaximumHitPoints.get([:elf, :wizard, 2])

  """
  @callback get(key() | [key()]) :: any()
end
