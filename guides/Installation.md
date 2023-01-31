# Installation

To create an ECSx application, there are a few simple steps:

  * install Elixir + erlang/OTP
  * install Phoenix (optional)
  * create an Elixir/Phoenix project
  * fetch ECSx as a dependency for your project
  * run the ECSx setup

## Elixir and erlang/OTP

If you don't yet have Elixir and erlang/OTP installed on your machine, follow the instructions on the official [Installation Page](https://elixir-lang.org/install.html).  

## Phoenix

If you plan on hosting your application online, you'll probably want to use Phoenix.  You can skip this step if you only want to run the app locally.  Otherwise, follow the instructions for Phoenix [installation](https://hexdocs.pm/phoenix/installation.html) (the tutorial project will assume you are using Phoenix).

## Create project

If you are using Phoenix, you'll create your new application with the command

```console
$ mix phx.new my_app
```

Or for a regular Elixir application (with supervision tree):

```console
$ mix new my_app --sup
```

## Install ECSx

To use the ECSx framework in your application, it should be added to the list of dependencies in `my_app/mix.exs`:

```
defp deps do
  [
    {:ecsx, "~> 0.3"}
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

which will create the Manager, and two folders to get your project started.

You'll also need to add the Manager to your application's supervision tree:

```elixir
def start(_type, _args) do
  children = [
    MyApp.Manager
  ]

  opts = [strategy: :one_for_one, name: MyApp.Supervisor]
  Supervisor.start_link(children, opts)
end
```

You should now have everything you need to start building!