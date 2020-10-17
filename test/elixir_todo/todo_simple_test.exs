defmodule TodoSimpleTest do
  use ExUnit.Case
  doctest ElixirTodo

  alias ElixirTodo.TodoSimple

  test "new/0 creates a new instance" do
    assert TodoSimple.new() == %{}
  end

  test "add_entry/3 inserts an entry" do
    todo_list =
      TodoSimple.new()
      |> TodoSimple.add_entry("2020-10-16", "Study Elixir")

    assert todo_list == %{"2020-10-16" => ["Study Elixir"]}
  end

  test "entries/2 fetches a title for a given date" do
    todo_list =
      TodoSimple.new()
      |> TodoSimple.add_entry("2020-10-16", "Study Elixir")
      |> TodoSimple.add_entry("2020-10-16", "Eat sushi")
      |> TodoSimple.add_entry("2020-10-20", "Study Kubernetes")

    assert TodoSimple.entries(todo_list, "2020-10-16") == ["Eat sushi", "Study Elixir"]
  end
end
