defmodule Todo.DatabaseTest do
  use ExUnit.Case, async: false
  alias Todo.Server, as: S

  setup_all do
    {:ok, db} = Todo.Database.start()

    on_exit(fn ->
      GenServer.stop(db)
    end)
  end

  setup do
    S.start("Tom")
    |> S.bind(&S.cleanup/1)
    |> S.bind(&S.add(&1, %{title: "excercise", date: ~D[2019-12-03]}))
    |> S.bind(&S.stop/1)

    :ok
  end

  test "load stored todo list from database" do
    {:ok, server} = S.start("Tom")
    assert [%{title: "excercise"}] = S.query(server, ~D[2019-12-03])
  end
end
