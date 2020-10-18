defmodule TodoEntryMapTest do
  use ExUnit.Case
  doctest ElixirTodo

  alias ElixirTodo.TodoEntryMap

  test "new/0 creates a new instance" do
    assert TodoEntryMap.new() == %{}
  end

  test "add_entry/3 inserts an entry" do
    entry = %{date: "2020-10-16", title: "Study Elixir"}

    todo_list =
      TodoEntryMap.new()
      |> TodoEntryMap.add_entry(entry)

    assert todo_list == %{"2020-10-16" => [entry]}
  end

  test "entries/2 fetches a title for a given date" do
    entry1 = %{date: "2020-10-16", title: "Study Elixir"}
    entry2 = %{date: "2020-10-16", title: "Eat sushi"}
    entry3 = %{date: "2020-10-20", title: "Study Kubernetes"}

    todo_list =
      TodoEntryMap.new()
      |> TodoEntryMap.add_entry(entry1)
      |> TodoEntryMap.add_entry(entry2)
      |> TodoEntryMap.add_entry(entry3)

    assert TodoEntryMap.entries(todo_list, "2020-10-16") == [entry2, entry1]
  end
end
