defmodule Todo.CacheTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, cache} = Todo.Cache.start()
    {:ok, db} = Todo.Database.start()
    :ok

    on_exit(fn ->
      GenServer.stop(cache)
      GenServer.stop(db)
    end)
  end

  test "get server from cache" do
    pid = Todo.Cache.server("Tom")
    assert pid != Todo.Cache.server("Jerry")
    assert pid == Todo.Cache.server("Tom")
  end

  test "bunch of servers" do
    1..1000 |> Enum.each(&Todo.Cache.server("Todo List No. #{&1}"))
    assert 1000 < :erlang.system_info(:process_count)
  end
end
