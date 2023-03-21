defmodule Mix.Tasks.Ecsx.Gen.Constant do
  @shortdoc "Generates a new ECSx Constant type"

  @moduledoc """
  Generates a new Constant type for an ECSx application.

      $ mix ecsx.gen.constant Name [key:value]

  The first argument is the name of the component, optionally followed by any number of `key:value` pairs, which will be injected into the generated module.

  ## Example

      $ mix ecsx.gen.constant PartLimit small:20 medium:50 large:100

  """

  use Mix.Task

  alias Mix.Tasks.ECSx.Helpers

  @doc false
  def run([]) do
    Mix.raise("""
    Invalid arguments.

    mix ecsx.gen.constant expects a module name (in PascalCase), optionally followed by key:value pairs.

    For example:

        $ mix ecsx.gen.constant PartLimit small:20 medium:50 large:100

    """)
  end

  def run([constant_name]) do
    filename = Macro.underscore(constant_name)
    target = "lib/#{Helpers.otp_app()}/constants/#{filename}.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/constant.ex")

    binding = [
      app_name: Helpers.root_module(),
      constant: constant_name,
      values: ""
    ]

    Mix.Generator.create_file(target, EEx.eval_file(source, binding))
  end

  def run([constant_name | values]) do
    parsed_values =
      values
      |> Enum.map(fn str ->
        str
        |> String.split(":")
        |> format_pair()
      end)
      |> Enum.intersperse([",", "\n"])
      |> List.insert_at(0, "\n")
      |> List.insert_at(-1, "\n    ")
      |> IO.iodata_to_binary()

    filename = Macro.underscore(constant_name)
    target = "lib/#{Helpers.otp_app()}/constants/#{filename}.ex"
    source = Application.app_dir(:ecsx, "/priv/templates/constant.ex")

    binding = [
      app_name: Helpers.root_module(),
      constant: constant_name,
      values: parsed_values
    ]

    File.write!("/Users/apb/dev/ecsx/output.txt", EEx.eval_file(source, binding))
    Mix.Generator.create_file(target, EEx.eval_file(source, binding) |> IO.inspect())
  end

  defp format_pair([k, v]) do
    {key, operator} = parse_key(k)
    value = parse_value(v)
    ["      ", key, operator, value]
  end

  defp parse_key(key) do
    case Integer.parse(key) do
      :error -> {key, ": "}
      {_int_key, ""} -> {key, " => "}
    end
  end

  defp parse_value(value) do
    case Integer.parse(value) do
      :error -> "\"#{value}\""
      {_, _} -> value
    end
  end
end
