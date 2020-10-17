defmodule MultiDictTest do
  use ExUnit.Case
  doctest ElixirTodo

  alias ElixirTodo.MultiDict

  test "new/0 creates a new instance" do
    assert MultiDict.new() == %{}
  end

  test "add/3 inserts an entry" do
    todo_list =
      MultiDict.new()
      |> MultiDict.add("2020-10-16", "Study Elixir")

    assert todo_list == %{"2020-10-16" => ["Study Elixir"]}
  end

  test "entries/2 fetches a title for a given date" do
    todo_list =
      MultiDict.new()
      |> MultiDict.add("2020-10-16", "Study Elixir")
      |> MultiDict.add("2020-10-16", "Eat sushi")
      |> MultiDict.add("2020-10-20", "Study Kubernetes")

    assert MultiDict.get(todo_list, "2020-10-16") == ["Eat sushi", "Study Elixir"]
  end
end
