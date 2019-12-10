defmodule Todo.Database do
  @moduledoc """
  persistent storage for todo list
  """
  @pool_size 3
  @db_folder "./persist"

  def child_spec(_) do
    File.mkdir_p!(@db_folder)

    :poolboy.child_spec(
      __MODULE__,
      [
        name: {:local, __MODULE__},
        worker_module: Todo.DatabaseWorker,
        size: @pool_size
      ],
      [@db_folder]
    )
  end

  def fetch(name) do
    :poolboy.transaction(__MODULE__, &Todo.DatabaseWorker.fetch(&1, name))
  end

  def store(todo_list) do
    :poolboy.transaction(__MODULE__, &Todo.DatabaseWorker.store(&1, todo_list))
  end
end
