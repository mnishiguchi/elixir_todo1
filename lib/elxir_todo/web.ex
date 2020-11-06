defmodule ElixirTodo.Web do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def child_spec(_args) do
    Plug.Adapters.Cowboy.child_spec(
      scheme: :http,
      options: [port: Application.fetch_env!(:elixir_todo, :http_port)],
      plug: __MODULE__
    )
  end

  # curl "http://localhost:5454/entries?list=bob&date=2018-12-19"
  get "/entries" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    entries =
      list_name
      |> ElixirTodo.Cache.server_process()
      |> ElixirTodo.Server.entries(date)

    formatted_entries =
      entries
      |> Enum.map(&"#{&1.date} #{&1.title}")
      |> Enum.join("\n")

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, formatted_entries)
  end

  # curl -X POST "http://localhost:5454/add_entry?list=bob&date=2018-12-19&title=Elixir"
  post "/add_entry" do
    conn = Plug.Conn.fetch_query_params(conn)
    list_name = Map.fetch!(conn.params, "list")
    title = Map.fetch!(conn.params, "title")
    date = Date.from_iso8601!(Map.fetch!(conn.params, "date"))

    list_name
    |> ElixirTodo.Cache.server_process()
    |> ElixirTodo.Server.add_entry(%{title: title, date: date})

    conn
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(200, "OK")
  end

  defp do_match("POST", ["add_entry"]) do
  end

  defp do_match("POST", ["delete_entry"]) do
  end

  defp do_match(_, _) do
  end
end
