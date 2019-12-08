defmodule Todo.CacheTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, system} = Todo.System.start_link()

    on_exit(fn ->
      # ? why doesn't work
      # Supervisor.stop(cache_spv)
      Process.exit(system, :shutdown)
    end)

    :ok
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
