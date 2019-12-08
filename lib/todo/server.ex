defmodule Todo.Server do
  use GenServer, restart: :temporary

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def add(server, entry), do: GenServer.cast(server, {:add, entry})
  def delete(server, id), do: GenServer.cast(server, {:delete, id})
  def update(server, id, k, v), do: GenServer.cast(server, {:update, id, k, v})
  def query(server, date), do: GenServer.call(server, {:query, date})
  def list(server), do: GenServer.call(server, :list)
  def cleanup(server), do: send(server, :cleanup)
  def stop(server), do: send(server, :terminate)

  defp via_tuple(name), do: Todo.Registry.via_tuple({__MODULE__, name})

  # defp bind(f) do
  #  fn result ->
  #    case result do
  #      {:error, _} -> result
  #      {{:error, _}, _} -> result
  #      {_, server} -> {f.(server), server}
  #    end
  #  end
  # end

  # Chaining world-crossing functions with "bind"
  # Monad: chain effects-generating functions in series
  # a bind function that converts a "diagonal" (world-crossing)
  # function into a "horizontal" (E-world-only) function
  def bind(result, f) do
    case result do
      {:error, _} ->
        result

      {{:error, _}, _} ->
        result

      {_, server} ->
        # a return function (lift)
        {f.(server), server}
    end
  end

  @impl GenServer
  def init(name) do
    IO.puts("starting server #{name}")
    {:ok, Todo.Database.fetch(name) || Todo.List.new(name)}
  end

  @impl GenServer
  def handle_cast({:add, entry}, state) do
    {:noreply, Todo.List.add(state, entry) |> store}
  end

  def handle_cast({:delete, id}, state) do
    {:noreply, Todo.List.delete(state, id) |> store}
  end

  def handle_cast({:update, id, k, v}, state) do
    {:noreply, Todo.List.update(state, id, k, v) |> store}
  end

  @impl GenServer
  def handle_call(:list, _, state) do
    {:reply, Todo.List.entries(state), state}
  end

  def handle_call({:query, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end

  @impl GenServer
  def handle_info(:cleanup, state) do
    {:noreply, Todo.List.new(state.name) |> store}
  end

  def handle_info(:terminate, state) do
    {:stop, :normal, state}
  end

  defp store(todo_list) do
    Todo.Database.store(todo_list)
    todo_list
  end
end
