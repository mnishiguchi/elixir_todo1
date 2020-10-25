defmodule ElixirTodo.DatabaseTest do
  use ExUnit.Case

  @db_directory "./tmp/test_database"

  setup do
    ElixirTodo.ProcessRegistry.start_link()

    on_exit(fn ->
      ElixirTodo.Database.clear(@db_directory)
    end)

    :ok
  end

  test "writes and reads data" do
    ElixirTodo.Database.start_link(db_directory: @db_directory)
    :timer.sleep(1)
    assert ElixirTodo.Database.store("language", "Elixir") == :ok
    assert ElixirTodo.Database.get("language") == "Elixir"
  end
end
