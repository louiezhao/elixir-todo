defmodule Todo.Database do
  @moduledoc """
  persistent storage for todo list
  """
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  def fetch(name), do: GenServer.call(__MODULE__, {:fetch, name})
  def store(todo_list), do: GenServer.cast(__MODULE__, {:store, todo_list})

  @worker_count 3

  @impl GenServer
  def init(_) do
    IO.puts("starting todo database")
    {:ok, 1..@worker_count |> Enum.map(&create_worker/1)}
  end

  @impl GenServer
  def handle_call({:fetch, name}, _, state) do
    todo_list =
      choose_worker(state, name)
      |> Todo.DatabaseWorker.fetch(name)

    {:reply, todo_list, state}
  end

  @impl GenServer
  def handle_cast({:store, todo_list}, state) do
    choose_worker(state, todo_list.name) |> Todo.DatabaseWorker.store(todo_list)
    {:noreply, state}
  end

  defp create_worker(_) do
    {:ok, worker} = Todo.DatabaseWorker.start()
    worker
  end

  defp choose_worker(state, name) do
    state
    |> Enum.at(:erlang.phash2(name, @worker_count))
  end
end
