defmodule Helper do
  import ExUnit.Assertions

  def shutdown(pid) do
    ref = Process.monitor(pid)
    Process.exit(pid, :shutdown)
    assert_receive({:DOWN, ^ref, :process, pid, :shutdown})
  end
end

ExUnit.start()
