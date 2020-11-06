defmodule ElixirTodo.DatabaseTest do
  use ExUnit.Case

  test "writes and reads data" do
    assert ElixirTodo.Database.store("language", "Elixir") == :ok
    assert ElixirTodo.Database.get("language") == "Elixir"
  end
end
