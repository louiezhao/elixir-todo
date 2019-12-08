defmodule Todo.CacheTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, cache_spv} = Todo.System.start_link()
    {:ok, db} = Todo.Database.start()
    :ok

    on_exit(fn ->
      # ? why doesn't work
      # Supervisor.stop(cache_spv)
      Process.exit(cache_spv, :shutdown)
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
