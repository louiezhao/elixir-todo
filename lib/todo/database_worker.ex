defmodule Todo.DatabaseWorker do
  @moduledoc """
  persistent storage for todo list
  """
  use GenServer

  def start_link(db_folder) do
    IO.puts("starting database worker")
    GenServer.start_link(__MODULE__, db_folder)
  end

  # Obsolete: (apply to pre-version before introducing poolboy)
  # Note: database workers' public interfaces expose `worker_id`
  # instead of `pid` (e.g. todo server) because workers are created statically
  # and pid query (via_tuple) is better to be hidden inside the implementation
  # By contrast, todo server is created/got dynamically and pid is exposed
  def fetch(worker, name), do: GenServer.call(worker, {:fetch, name})
  def store(worker, todo_list), do: GenServer.cast(worker, {:store, todo_list})

  @impl GenServer
  def init(db_folder) do
    {:ok, db_folder}
  end

  @impl GenServer
  def handle_call({:fetch, name}, _, db_folder) do
    todo_list =
      case File.read(file_path(db_folder, name)) do
        {:ok, data} -> :erlang.binary_to_term(data)
        _ -> nil
      end

    todo_list && IO.puts("database worker <-: read #{name}")
    {:reply, todo_list, db_folder}
  end

  @impl GenServer
  def handle_cast({:store, todo_list}, db_folder) do
    file_path(db_folder, todo_list.name)
    |> File.write!(:erlang.term_to_binary(todo_list))

    IO.puts("database worker ->: write #{todo_list.name}")
    {:noreply, db_folder}
  end

  defp file_path(db_folder, name), do: Path.join(db_folder, name)
  # defp via_tuple(worker_id), do: Todo.Registry.via_tuple({__MODULE__, worker_id})
end
