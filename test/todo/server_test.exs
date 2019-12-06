defmodule Todo.ServerTest do
  use ExUnit.Case, async: false

  setup_all do
    {:ok, db} = Todo.Database.start()
    :ok
    on_exit(fn -> GenServer.stop(db) end)
  end

  test "server process" do
    {:ok, server} = Todo.Server.start("Bob")

    [
      {:add, %{date: ~D[2016-08-09], title: "Dentist"}},
      {:add, %{date: ~D[2017-09-12], title: "Reservation"}},
      {:add, %{date: ~D[2017-09-12], title: "Traveling"}},
      {:add, %{date: ~D[2018-03-01], title: "Shopping"}},
      {:update, 9, :title, "Reservation 1"},
      {:update, 3, :title, "Travel Tokyo"},
      {:update, 3, :date, ~D[2017-09-20]},
      {:delete, 9},
      {:delete, 2},
      {:add, %{date: ~D[2019-02-09], title: "Beijing"}}
    ]
    |> Enum.each(&Todo.Server.execute(server, &1))

    assert [%{title: "Travel Tokyo"}] = Todo.Server.query(server, ~D[2017-09-20])
    assert 4 = Todo.Server.list(server) |> Enum.count()
    Todo.Server.cleanup(server)
    assert 0 = Todo.Server.list(server) |> Enum.count()
    Process.sleep(1000)
  end
end
