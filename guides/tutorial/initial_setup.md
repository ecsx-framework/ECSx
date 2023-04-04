# Initial Setup

To demonstrate ECSx in a real-time application, we're going to make a game where each player will control a ship, which can sail around the map, and will attack enemies if they come too close.

> Note:  This guide will get you up-and-running with a working game, but it is intentionally generic.  Feel free to experiment with altering details from this implementation to customize your own game.

* First, ensure you have installed [Elixir](https://elixir-lang.org/install.html) and [Phoenix](https://hexdocs.pm/phoenix/installation.html).
* Create the application by running `mix phx.new ship`
* Add `{:ecsx, "~> 0.3"}` to your `mix.exs` deps
* Add `{:ecto, "~> 3.9"}` to your `mix.exs` deps (for `Ecto.UUID.generate()`)
* Add `{:phoenix, "~> 1.7.2"}` and `{:phoenix_live_view, "~> 0.18.17"}` to your `mix.exs` deps (for our front end)
* Run `mix deps.get`
* Run `mix ecsx.setup`


