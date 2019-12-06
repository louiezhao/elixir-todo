defmodule Todo.Database do
  use GenServer

  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)
  def fetch(name), do: GenServer.call(__MODULE__, {:fetch, name})
  def store(todo_list), do: GenServer.cast(__MODULE__, {:store, todo_list})

  @dir "./persist"

  @impl GenServer
  def init(_) do
    File.mkdir_p(@dir)
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:fetch, name}, _, state) do
    todo_list =
      case File.read(file_path(name)) do
        {:ok, data} -> :erlang.binary_to_term(data)
        _ -> nil
      end

    {:reply, todo_list, state}
  end

  @impl GenServer
  def handle_cast({:store, todo_list}, state) do
    todo_list.name
    |> file_path
    |> File.write!(:erlang.term_to_binary(todo_list))

    {:noreply, state}
  end

  defp file_path(name), do: Path.join(@dir, name)
end
