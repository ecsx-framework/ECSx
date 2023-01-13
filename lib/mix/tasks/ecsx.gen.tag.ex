defmodule Mix.Tasks.Ecsx.Gen.Tag do
  @shortdoc "Generates a new ECSx Tag - a Component type which doesn't store any value"

  @moduledoc """
  Generates a new ECSx Tag - a Component type which doesn't store any value.

      $ mix ecsx.gen.tag Attackable

  The single argument is the name of the component.
  """

  use Mix.Task

  alias Mix.Tasks.ECSx.Helpers

  @doc false
  def run([]) do
    "Invalid arguments."
    |> message_with_help()
    |> Mix.raise()
  end

  def run([tag_name | _]) do
    Helpers.inject_component_module_into_manager(tag_name)
    create_component_file(tag_name)
  end

  defp message_with_help(message) do
    """
    #{message}

    mix ecsx.gen.tag expects a tag module name (in PascalCase).

    For example:

        mix ecsx.gen.tag MyTag

    """
  end

  defp create_component_file(tag_name) do
    filename = Macro.underscore(tag_name)
    target = "lib/#{Helpers.otp_app()}/components/#{filename}.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/tag.ex")
    binding = [app_name: Helpers.root_module(), tag_name: tag_name]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end
end
