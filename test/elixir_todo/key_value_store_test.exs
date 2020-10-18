defmodule KeyValueStoreTest do
  use ExUnit.Case
  doctest ElixirTodo

  alias ElixirTodo.KeyValueStore

  setup do
    {:ok, server_pid} = KeyValueStore.start()
    {:ok, server_pid: server_pid}
  end

  test "put and get", %{server_pid: server_pid} do
    assert KeyValueStore.put(server_pid, "2020-10-16", "Study Elixir") == :ok
    assert KeyValueStore.get(server_pid, "2020-10-16") == "Study Elixir"
  end
end
