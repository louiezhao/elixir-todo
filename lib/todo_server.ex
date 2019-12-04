defmodule TodoServer do
  use GenServer

  def start(entries \\ []) do
    GenServer.start(__MODULE__, entries, name: __MODULE__)
  end

  def add(entry), do: GenServer.cast(__MODULE__, {:add, entry})
  def delete(id), do: GenServer.cast(__MODULE__, {:delete, id})
  def update(id, k, v), do: GenServer.cast(__MODULE__, {:update, id, k, v})
  def query(date), do: GenServer.call(__MODULE__, {:query, date})
  def list, do: GenServer.call(__MODULE__, :list)

  def execute({:add, entry}), do: add(entry)
  def execute({:delete, id}), do: delete(id)
  def execute({:update, id, k, v}), do: update(id, k, v)

  def cleanup, do: send(__MODULE__, :cleanup)

  @impl GenServer
  def init(entries) do
    {:ok, TodoList.new(entries)}
  end

  @impl GenServer
  def handle_cast({:add, entry}, state) do
    {:noreply, TodoList.add(state, entry)}
  end

  def handle_cast({:delete, id}, state) do
    {:noreply, TodoList.delete(state, id)}
  end

  def handle_cast({:update, id, k, v}, state) do
    {:noreply, TodoList.update(state, id, k, v)}
  end

  @impl GenServer
  def handle_call(:list, _, state) do
    {:reply, TodoList.entries(state), state}
  end

  def handle_call({:query, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
  end

  @impl GenServer
  def handle_info(:cleanup, _) do
    {:noreply, TodoList.new()}
  end
end
