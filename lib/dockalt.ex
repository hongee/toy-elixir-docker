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

  Try the following commands:
    list
    new
    start <name-of-container>
    stop <name-of-container>
  ...
  """

  @avail_cmds %{
    list: {1, :dock_list},
    new: {1, :dock_new},
    start: {2, :dock_start},
    stop: {2, :dock_stop},
  }

  def main(args \\ []) do
    opts = args
    |> parse_args
    IO.puts @desc

    Dockalt.ContainerManager.start_manager()
    for _ <- 1..opts[:count] do
      Dockalt.ContainerManager.dock_new(nil)
    end

    io_loop()
  end

  defp io_loop() do
    input =
      IO.gets("dockalt:~ ")
      |> String.replace("\n", "")
      |> String.replace("\r", "")
      |> String.split(" ")
      |> Enum.map(&String.to_atom/1)

    cond do
      !@avail_cmds[hd(input)] ->
        IO.puts "[Error] Unrecognized Input"
      elem(@avail_cmds[hd(input)], 0) != length(input) ->
        IO.puts "[Error] Incorrect number of arguments for #{hd(input)}."
      true ->
        {time, _} = :timer.tc(Dockalt.ContainerManager, elem(@avail_cmds[hd(input)], 1), [input])
        IO.puts "Operation completed in #{time/1000}ms."
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

end

defmodule Dockalt.Container do
  @enforce_keys [:name]
  defstruct name: nil, state: :stopped, load: 0.0

  def load_proc() do
    Process.sleep(100)
    :rand.uniform()
  end

  def cur_state(state) do
    if state.state == :stopped do
      state
    else
      t = Task.async(&load_proc/0)
      %{state | load: Task.await(t)} #can also yield
    end
  end

  def start(state) do
    if state.state == :stopped do
      %{state | state: :started}
    end
  end

  def stop(state) do
    if state.state == :started do
      %{state | state: :stopped, load: 0.0}
    end
  end

end

defmodule Dockalt.ContainerManager do
  @name_vars [
    "rich",
    "pineapple",
    "turnip",
    "jackfruit",
    "chimpanzee",
    "navajo",
    "trump",
    "obama",
    "biden",
    "clinton",
    "apple",
    "cupcake",
    "cheeseburger",
    "fried",
    "smelly"
  ]

  def name_vars, do: @name_vars

  def start_manager do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def dock_list(_) do
    IO.puts "..."
    ls =
      Agent.get(__MODULE__, &get_proc_states/1)
      |> Enum.map(fn {_, v} ->
            IO.puts "#{v.name} load: #{v.load} state: #{v.state}"
          end)

    IO.puts """
    ...
    #{length(ls)} total containers
    """
  end

  def dock_new(_) do
    name =
      @name_vars
      |> Enum.take_random(3)
      |> Enum.join("-")

    Agent.update(__MODULE__, &spin_new_proc(&1, name))
    IO.puts "Added #{name}."
  end

  def dock_start([_|name]) do
    s_name = to_string(List.first(name))

    if Agent.get_and_update(__MODULE__, &start_container(&1, s_name)) do
      IO.puts "Starting #{s_name}."
    else
      IO.puts "#{s_name} does not exist."
    end
  end

  def dock_stop([_|name]) do
    s_name = to_string(List.first(name))

    if Agent.get_and_update(__MODULE__, &start_container(&1, s_name, true)) do
      IO.puts "Stopping #{s_name}."
    else
      IO.puts "#{s_name} does not exist."
    end
  end

  defp spin_new_proc(state, name) do
    {:ok, ctr} = Agent.start_link(fn -> %Dockalt.Container{name: name} end)
    Map.put(state, name, ctr)
  end

  defp get_proc_states(state) do
    state
    |> Enum.map(fn {k,v} ->
      t = Task.async(fn -> Agent.get(v, &Dockalt.Container.cur_state(&1)) end)
      {k, t}
    end)
    |> Enum.map(fn {k,t} ->
      {k, Task.await(t)}
    end)
  end

  defp start_container(state, name, or_stop? \\ false) do
    case Map.get(state, name) do
      nil ->
        {false, state}
      a ->
        case or_stop? do
          true ->
            Agent.update(a, &Dockalt.Container.stop(&1))
          false->
            Agent.update(a, &Dockalt.Container.start(&1))
        end
        {true, state}
    end
  end
end
