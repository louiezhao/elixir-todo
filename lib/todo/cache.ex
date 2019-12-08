defmodule Todo.Cache do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server(name) do
    GenServer.call(__MODULE__, {:server_process, name})
  end

  def init(_) do
    IO.puts("starting cache")
    {:ok, %{}}
  end

  def handle_call({:server_process, name}, _, todo_servers) do
    case Map.fetch(todo_servers, name) do
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = Todo.Server.start(name)
        {:reply, new_server, Map.put_new(todo_servers, name, new_server)}
    end
  end
end
