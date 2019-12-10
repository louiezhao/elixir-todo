defmodule Todo.CacheTest do
  use ExUnit.Case, async: false

  # setup_all do
  #  {:ok, system} = Todo.System.start_link()

  #  # ? what is Supervisor.stop for?
  #  on_exit(fn -> Helper.assert_exit(system) end)

  #  :ok
  # end

  test "get server from cache" do
    pid = s("Tom")
    assert pid != s("Jerry")
    assert pid == s("Tom")
  end

  test "bunch of servers" do
    1..100 |> Enum.each(&s("No. #{&1}"))
    assert 100 < :erlang.system_info(:process_count)
  end

  test "restart cache" do
    cid = cache_pid()
    tid = s("Tom")
    assert 2 == Supervisor.count_children(system_pid()).supervisors

    # ? whey :shutdown signal doesn't work with database and cache, but with system
    # https://stackoverflow.com/questions/51651731/supervisor-restart-child-2-or-process-exitpid-kill
    # Helper.shutdown(cid)
    Helper.assert_exit(cid, :kill)

    assert 2 == Supervisor.count_children(system_pid()).supervisors
    assert cid != cache_pid()
    assert tid != s("Tom")
  end

  test "dynamic server" do
    tid = s("Tom")
    worker_count = Supervisor.count_children(cache_pid()).workers

    Helper.assert_exit(tid, :kill)

    assert worker_count - 1 == Supervisor.count_children(cache_pid()).workers
  end

  defp s(name) do
    {:ok, pid} = Todo.Cache.server(name)
    pid
  end

  defp cache_pid, do: Process.whereis(Todo.Cache)
  defp system_pid, do: Process.whereis(Todo.System)
end
