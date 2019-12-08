defmodule Todo.CacheTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, system} = Todo.System.start_link()

    # ? what is Supervisor.stop for?
    on_exit(fn -> Helper.shutdown(system) end)

    :ok
  end

  test "get server from cache" do
    pid = Todo.Cache.server("Tom")
    assert pid != Todo.Cache.server("Jerry")
    assert pid == Todo.Cache.server("Tom")
  end

  test "bunch of servers" do
    1..100 |> Enum.each(&Todo.Cache.server("No. #{&1}"))
    assert 100 < :erlang.system_info(:process_count)
  end

  test "restart cache" do
    cache = fn -> Process.whereis(Todo.Cache) end
    tom = fn -> Todo.Cache.server("Tom") end

    cid = cache.()
    tid = tom.()

    Helper.shutdown(cid)
    Process.sleep(100)

    assert cid != cache.()
    assert tid != tom.()
  end
end
