defmodule ElixirTodo.DatabaseWorkerTest do
  use ExUnit.Case

  @db_directory "./tmp/test_database"

  setup do
    ElixirTodo.ProcessRegistry.start_link()

    on_exit(fn ->
      ElixirTodo.DatabaseWorker.clear(@db_directory)
    end)

    :ok
  end

  test "writes and reads data" do
    {:ok, pid} =
      ElixirTodo.DatabaseWorker.start_link(db_directory: @db_directory, worker_id: 1234)

    assert ElixirTodo.DatabaseWorker.store(1234, "language", "Elixir") == :ok
    assert ElixirTodo.DatabaseWorker.get(1234, "language") == "Elixir"

    :ok = ElixirTodo.DatabaseWorker.stop(1234)
  end
end
