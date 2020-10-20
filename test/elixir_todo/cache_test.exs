defmodule ElixirTodo.CacheTest do
  use ExUnit.Case

  setup do
    {:ok, cache_pid} = ElixirTodo.Cache.start()

    on_exit(fn ->
      :ok = ElixirTodo.Cache.stop(cache_pid)
    end)

    {:ok, cache_pid: cache_pid}
  end

  test "can start multiple server processes", %{cache_pid: cache_pid} do
    server_pid1 = ElixirTodo.Cache.server_process(cache_pid, "Foo's")
    server_pid2 = ElixirTodo.Cache.server_process(cache_pid, "Bar's")
    assert server_pid1 != server_pid2

    # for i <- 1..10 do
    #   ElixirTodo.Cache.server_process(cache_pid, "to-do list #{i}")
    # end

    # IO.inspect(length(:erlang.processes()))
  end
end
