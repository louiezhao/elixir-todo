defmodule Helper do
  import ExUnit.Assertions

  def assert_exit(pid, signal \\ :shutdown) do
    ref = Process.monitor(pid)
    Process.exit(pid, signal)
    assert_receive({:DOWN, ^ref, :process, pid, signal})
  end
end

ExUnit.start()
