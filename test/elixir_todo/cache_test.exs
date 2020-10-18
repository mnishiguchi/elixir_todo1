defmodule ElixirTodo.CacheTest do
  use ExUnit.Case

  setup do
    {:ok, cache_pid} = ElixirTodo.Cache.start()
    IO.puts("\nServer started")

    on_exit(fn ->
      :ok = ElixirTodo.Cache.stop(cache_pid)
      IO.puts("Server stopped")
    end)

    {:ok, cache_pid: cache_pid}
  end

  test "can start multiple server processes", %{cache_pid: cache_pid} do
    server_pid1 = ElixirTodo.Cache.server_process(cache_pid, "Foo's")
    server_pid2 = ElixirTodo.Cache.server_process(cache_pid, "Bar's")
    assert server_pid1 != server_pid2

    server_pid1 |> ElixirTodo.Server.add_entry(%{date: "2020-10-18", title: "Study Elixir"})

    server_pid1
    |> ElixirTodo.Server.entries("2020-10-18")
    |> Kernel.==([%{id: 1, date: "2020-10-18", title: "Study Elixir"}])
    |> assert

    # for i <- 1..100_000 do
    #   ElixirTodo.Cache.server_process(cache_pid, "to-do list #{i}")
    # end

    # IO.inspect(length(:erlang.processes()))
  end
end
