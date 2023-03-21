Code.require_file("../../support/mix_helper.exs", __DIR__)

defmodule Mix.Tasks.Ecsx.Gen.ConstantTest do
  use ExUnit.Case

  import ECSx.MixHelper

  setup do
    create_sample_ecsx_project()
    on_exit(&clean_tmp_dir/0)
    :ok
  end

  test "no values" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Constant.run(["FooConstant"])

      constant_file = File.read!("lib/my_app/constants/foo_constant.ex")

      assert constant_file ==
               """
               defmodule MyApp.Constants.FooConstant do
                 @moduledoc \"\"\"
                 Documentation for FooConstant.
                 \"\"\"
                 use ECSx.Constant,
                   values: %{}
               end
               """
    end)
  end

  test "text keys" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Constant.run(["FooConstant", "bar:baz", "uno:dos"])

      constant_file = File.read!("lib/my_app/constants/foo_constant.ex")

      assert constant_file ==
               """
               defmodule MyApp.Constants.FooConstant do
                 @moduledoc \"\"\"
                 Documentation for FooConstant.
                 \"\"\"
                 use ECSx.Constant,
                   values: %{
                     bar: "baz",
                     uno: "dos"
                   }
               end
               """
    end)
  end

  test "integer keys" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Constant.run(["FooConstant", "1:foo", "2:bar", "3:baz"])

      constant_file = File.read!("lib/my_app/constants/foo_constant.ex")

      assert constant_file ==
               """
               defmodule MyApp.Constants.FooConstant do
                 @moduledoc \"\"\"
                 Documentation for FooConstant.
                 \"\"\"
                 use ECSx.Constant,
                   values: %{
                     1 => "foo",
                     2 => "bar",
                     3 => "baz"
                   }
               end
               """
    end)
  end

  test "float values" do
    Mix.Project.in_project(:my_app, ".", fn _module ->
      Mix.Tasks.Ecsx.Gen.Constant.run(["FooConstant", "foo:1.234", "bar:105.1"])

      constant_file = File.read!("lib/my_app/constants/foo_constant.ex")

      assert constant_file ==
               """
               defmodule MyApp.Constants.FooConstant do
                 @moduledoc \"\"\"
                 Documentation for FooConstant.
                 \"\"\"
                 use ECSx.Constant,
                   values: %{
                     foo: 1.234,
                     bar: 105.1
                   }
               end
               """
    end)
  end
end
