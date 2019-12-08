defmodule Todo.System do
  def start_link do
    IO.puts("starting system")

    Supervisor.start_link([Todo.Cache, Todo.Registry, Todo.Database],
      name: __MODULE__,
      strategy: :one_for_one
    )
  end
end
