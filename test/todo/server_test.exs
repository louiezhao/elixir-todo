defmodule Todo.ServerTest do
  use ExUnit.Case, async: false
  alias Todo.Server, as: S

  setup_all do
    {:ok, db} = Todo.Database.start()
    on_exit(fn -> GenServer.stop(db) end)
    :ok
  end

  test "server process" do
    {_, server} =
      S.start("Bob")
      |> S.bind(&S.add(&1, %{date: ~D[2016-08-09], title: "Dentist"}))
      |> S.bind(&S.add(&1, %{date: ~D[2017-09-12], title: "Reservation"}))
      |> S.bind(&S.add(&1, %{date: ~D[2017-09-12], title: "Traveling"}))
      |> S.bind(&S.add(&1, %{date: ~D[2018-03-01], title: "Shopping"}))
      |> S.bind(&S.update(&1, 9, :title, "Reservation 1"))
      |> S.bind(&S.update(&1, 3, :title, "Travel Tokyo"))
      |> S.bind(&S.update(&1, 3, :date, ~D[2017-09-20]))
      |> S.bind(&S.delete(&1, 9))
      |> S.bind(&S.delete(&1, 2))
      |> S.bind(&S.add(&1, %{date: ~D[2019-02-09], title: "Beijing"}))

    assert [%{title: "Travel Tokyo"}] = S.query(server, ~D[2017-09-20])
    assert 4 = S.list(server) |> Enum.count()
    S.cleanup(server)
    assert 0 = S.list(server) |> Enum.count()
    Process.sleep(1000)
  end
end
