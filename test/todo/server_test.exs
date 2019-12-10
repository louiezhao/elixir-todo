defmodule Todo.ServerTest do
  use ExUnit.Case, async: false
  import Todo.Server

  # setup_all do
  #  {:ok, system} = Todo.System.start_link()

  #  on_exit(fn -> Helper.assert_exit(system) end)

  #  :ok
  # end

  setup do
    # ensure async database operation to finish
    on_exit(fn -> Process.sleep(100) end)
    :ok
  end

  test "server process" do
    {_, server} =
      start_link("Bob")
      |> bind(&add(&1, %{date: ~D[2016-08-09], title: "Dentist"}))
      |> bind(&add(&1, %{date: ~D[2017-09-12], title: "Reservation"}))
      |> bind(&add(&1, %{date: ~D[2017-09-12], title: "Traveling"}))
      |> bind(&add(&1, %{date: ~D[2018-03-01], title: "Shopping"}))
      |> bind(&update(&1, 9, :title, "Reservation 1"))
      |> bind(&update(&1, 3, :title, "Travel Tokyo"))
      |> bind(&update(&1, 3, :date, ~D[2017-09-20]))
      |> bind(&delete(&1, 9))
      |> bind(&delete(&1, 2))
      |> bind(&add(&1, %{date: ~D[2019-02-09], title: "Beijing"}))

    assert [%{title: "Travel Tokyo"}] = query(server, ~D[2017-09-20])
    assert 4 = list(server) |> Enum.count()
    cleanup(server)
    assert 0 = list(server) |> Enum.count()
  end

  test "timeout" do
    {_, server} = start_link("Bob")
    Process.sleep(:timer.seconds(4))
    assert !Process.alive?(server)
  end
end
