defmodule ElixirTodo.CacheTest do
  use ExUnit.Case

  setup do
    ElixirTodo.Cache.start_link([])
    :ok
  end

  test "can start multiple server processes" do
    server_pid1 = ElixirTodo.Cache.server_process("Foo's")
    server_pid2 = ElixirTodo.Cache.server_process("Bar's")
    assert server_pid1 != server_pid2

    # for i <- 1..10 do
    #   ElixirTodo.Cache.server_process("to-do list #{i}")
    # end

    # IO.inspect(length(:erlang.processes()))
  end
end
