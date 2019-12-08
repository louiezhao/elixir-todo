defmodule Todo.System do
  use Supervisor

  def start_link, do: Supervisor.start_link(__MODULE__, nil)

  def init(_) do
    IO.puts("starting system")
    Supervisor.init([Todo.Cache, Todo.Registry, Todo.Database], strategy: :one_for_one)
  end
end
