defmodule Todo.Database do
  @moduledoc """
  persistent storage for todo list
  """
  @pool_size 3
  @db_folder "./persist"

  def start_link() do
    IO.puts("starting database")
    File.mkdir_p!(@db_folder)
    children = 1..@pool_size |> Enum.map(&worker_spec/1)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  defp worker_spec(worker_id) do
    Supervisor.child_spec({Todo.DatabaseWorker, {@db_folder, worker_id}}, id: worker_id)
  end

  def fetch(name) do
    name |> choose_worker |> Todo.DatabaseWorker.fetch(name)
  end

  def store(todo_list) do
    todo_list.name |> choose_worker |> Todo.DatabaseWorker.store(todo_list)
  end

  defp choose_worker(name) do
    :erlang.phash(name, @pool_size)
  end
end
