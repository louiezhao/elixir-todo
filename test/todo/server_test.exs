defmodule Todo.ServerTest do
  use ExUnit.Case, async: false
  alias Todo.Server, as: S

  setup_all do
    {:ok, system} = Todo.System.start_link()

    on_exit(fn -> Helper.assert_exit(system) end)

    :ok
  end

  setup do
    # ensure async database operation to finish
    on_exit(fn -> Process.sleep(100) end)
    :ok
  end

  test "server process" do
    {_, server} =
      S.start_link("Bob")
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
  end

  test "timeout" do
    {_, server} = S.start_link("Bob")
    Process.sleep(:timer.seconds(4))
    assert !Process.alive?(server)
  end
end
