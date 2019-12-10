defmodule Todo.Web do
  use Plug.Router
  import Todo.Server, only: [query: 2, bind: 2, add: 2]

  plug(:match)
  plug(:dispatch)

  def child_spec(__args) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: 8080],
      plug: __MODULE__
    )
  end

  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> Todo.Cache.server()
    |> bind(&add(&1, %{date: date, title: title}))

    conn |> Plug.Conn.put_resp_content_type("text/plain") |> Plug.Conn.send_resp(200, "OK")
  end

  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    {entries, _} =
      list_name
      |> Todo.Cache.server()
      |> bind(&query(&1, date))

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.title}")
      |> Enum.join("\n")

    IO.puts(formatted_entries)

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end
end
