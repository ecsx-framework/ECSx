# Installation

To create an ECSx application, there are a few simple steps:

  * install Elixir + erlang/OTP
  * create an Elixir project
  * fetch ECSx as a dependency for your project
  * run the ECSx setup

## Elixir and erlang/OTP

If you don't yet have Elixir and erlang/OTP installed on your machine, follow the instructions on the official [Installation Page](https://elixir-lang.org/install.html).  

## Create project

To create a new Elixir application with supervision tree, run the following command:

```console
$ mix new my_app --sup
```

Where `my_app` will be the name of your app.

If you want to use the [Phoenix Web Framework](https://hexdocs.pm/phoenix/overview.html), instead run (after hex and phx_new are installed):

```console
$ mix phx.new my_app
```

## Install ECSx

To use the ECSx framework in your application, it should be added to the list of dependencies in `my_app/mix.exs`:

```
defp deps do
  [
    {:ecsx, "~> 0.1"}
  ]
end
```

Then (from the root directory of your application) run:

```console
$ mix deps.get
```

## Setup ECSx

With ECSx installed, you can run the setup generator:

```console
$ mix ecsx.setup
```

which will create the Manager, a sample Aspect, and a sample System to get your project started.

## Summary

You should now have everything you need to start building!  If you're already familiar with the Entity-Component-System pattern, jump right in to the [tutorial project](tutorial.md) - otherwise, start with our guide on [ECS design](ecs_design.md).
