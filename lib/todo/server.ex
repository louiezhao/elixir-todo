defmodule Todo.Server do
  use GenServer

  def start(name) do
    GenServer.start(__MODULE__, name)
  end

  def add(server, entry), do: GenServer.cast(server, {:add, entry})
  def delete(server, id), do: GenServer.cast(server, {:delete, id})
  def update(server, id, k, v), do: GenServer.cast(server, {:update, id, k, v})
  def query(server, date), do: GenServer.call(server, {:query, date})
  def list(server), do: GenServer.call(server, :list)

  def execute(server, {:add, entry}), do: add(server, entry)
  def execute(server, {:delete, id}), do: delete(server, id)
  def execute(server, {:update, id, k, v}), do: update(server, id, k, v)

  def cleanup(server), do: send(server, :cleanup)

  @impl GenServer
  def init(name) do
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

  defp store(todo_list) do
    Todo.Database.store(todo_list)
    todo_list
  end
end
