defmodule Todo.DatabaseWorkerTest do
  use ExUnit.Case, async: false
  import Todo.Server

  # setup_all do
  #  {:ok, system} = Todo.System.start_link()

  #  on_exit(fn -> Helper.assert_exit(system) end)

  #  :ok
  # end

  setup do
    start_link("Tom")
    |> bind(&cleanup/1)
    |> bind(&add(&1, %{title: "excercise", date: ~D[2019-12-03]}))
    |> bind(&stop/1)

    # ? database work may be killed during work
    # that make the file corrupted (size = 0)
    # how to shutdown the database work gracefully

    # ? wait for database worker to complete writing
    # any more elegant solution?
    on_exit(fn -> Process.sleep(100) end)

    Process.sleep(100)

    :ok
  end

  test "load stored todo list from database" do
    {:ok, server} = start_link("Tom")
    assert [%{title: "excercise"}] = query(server, ~D[2019-12-03])
  end
end
