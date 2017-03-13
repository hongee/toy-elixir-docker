defmodule Dockalt do
  @moduledoc """
  Documentation for Dockalt.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Dockalt.hello
      :world

  """
  @desc """
  ...
  Dockalt is a toy(fake) implementation of Docker in Elixir
  Conclusion: Elixir is awesome

  Try the following commands:
    list
    new
    start <name-of-container>
    stop <name-of-container>
    state <name-of-container>
  ...
  """

  @avail_cmds %{
    list: {1, :dock_list},
    new: {1, :dock_new},
    start: {2, :dock_start},
    stop: {2, :dock_stop},
    state: {2, :dock_state}
  }

  def main(args \\ []) do
    opts = args
    |> parse_args
    IO.puts @desc

    io_loop()
  end

  defp io_loop() do
    input =
      IO.gets("dockalt:~ ")
      |> String.replace("\n", "")
      |> String.replace("\r", "")
      |> String.split(" ")
      |> Enum.map(&String.to_atom/1)

    #IO.inspect input
    
    cond do
      !@avail_cmds[hd(input)] ->
        IO.puts "[Error] Unrecognized Input"
      elem(@avail_cmds[hd(input)], 0) != length(input) ->
        IO.puts "[Error] Incorrect number of arguments for #{hd(input)}."
      true ->
        apply(Dockalt, elem(@avail_cmds[hd(input)], 1), input)
    end

    io_loop()
  end

  defp parse_args(args) do
    {opts, _, _} =
      args
      |> OptionParser.parse(switches: [count: :integer])

    case opts do
      [] ->
        IO.puts "[WARN] No initial container count given. Defaulting to 1."
        opts ++ [count: 1]
      _ ->
        opts
    end
  end

  def dock_list(args) do
    IO.puts "[ERR] Not yet implemented."
  end

  def dock_new(args) do
    IO.puts "[ERR] Not yet implemented."
  end

  def dock_start(args) do
    IO.puts "[ERR] Not yet implemented."
  end

  def dock_stop(args) do
    IO.puts "[ERR] Not yet implemented."
  end

  def dock_state(args) do
    IO.puts "[ERR] Not yet implemented."
  end


end

defmodule Dockalt.Container do
  @name_vars [
    "rich",
    "pineapple",
    "turnip",
    "jackfruit",
    "chimpanzee",
    "navajo",
    "trump",
    "bama",
    "biden",
    "apple",
    "cupcake",
    "cheeseburger"
  ]

  def name_vars, do: @name_vars
end
