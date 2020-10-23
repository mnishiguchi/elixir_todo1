defmodule ElixirTodo.DatabaseWorkerTest do
  use ExUnit.Case

  @db_directory "./tmp/test_database"

  setup do
    on_exit(fn ->
      ElixirTodo.DatabaseWorker.clear(@db_directory)
    end)

    :ok
  end

  test "writes and reads data" do
    {:ok, pid} = ElixirTodo.DatabaseWorker.start_link(@db_directory)
    assert ElixirTodo.DatabaseWorker.store(pid, "language", "Elixir") == :ok
    assert ElixirTodo.DatabaseWorker.get(pid, "language") == "Elixir"
    :ok = ElixirTodo.DatabaseWorker.stop(pid)
  end
end
