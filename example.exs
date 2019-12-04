defmodule Example do
  def run do
    [
      %{date: ~D[2016-08-09], title: "Dentist"},
      %{date: ~D[2017-09-12], title: "Reservation"},
      %{date: ~D[2017-09-12], title: "Traveling"},
      %{date: ~D[2018-03-01], title: "Shopping"}
    ]
    |> TodoServer.start()

    [
      {:update, 9, :title, "Reservation 1"},
      {:update, 2, :title, "Reservation 2"},
      {:update, 3, :date, ~D[2017-09-20]},
      {:delete, 9},
      {:delete, 2},
      {:add, %{date: ~D[2019-02-09], title: "Beijing"}}
    ]
    |> Enum.each(&TodoServer.execute/1)

    TodoServer.query(~D[2017-09-20]) |> IO.inspect()
    TodoServer.list() |> IO.inspect()
    TodoServer.cleanup()
    TodoServer.list() |> IO.inspect()
  end
end

Example.run()
