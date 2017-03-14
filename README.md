# Dockalt
This is a toy version of Docker implemented in Elixir. It does absolutely
nothing, and only serves to showcase how one might use Elixir/Erlang's Actor
concurrency model to build an application like Docker.

## Running
With the Erlang VM installed, the binary can be ran with `./dockalt`. Use `./dockalt --count [NUM]` to start the app with more than one container.

## Using Dockalt
The following commands are available in the dockalt "shell":
- `list`
  - lists all existing containers and their state
- `new`
  - create a new container
- `start <name-of-container>`
  - start a container
- `stop <name-of-container>`
  - stop a container

## Compiling
This app has only been built (and tested) with Elixir 1.4.2.
With Elixir properly installed and configured, the app binary can be built with `mix escript.build`.
