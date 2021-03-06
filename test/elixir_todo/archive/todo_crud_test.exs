defmodule TodoCrudTest do
  use ExUnit.Case
  doctest ElixirTodo

  alias ElixirTodo.TodoCrud

  test "new/0 creates a new instance" do
    assert TodoCrud.new() == %TodoCrud{auto_id: 1, collection: %{}}
  end

  test "new/1 creates a new instance with specified entries" do
    entries_to_create = [
      %{date: "2020-10-16", title: "Study Elixir"},
      %{date: "2020-10-17", title: "Eat sushi"}
    ]

    assert TodoCrud.new(entries_to_create) == %TodoCrud{
             auto_id: 3,
             collection: %{
               1 => %{id: 1, date: "2020-10-16", title: "Study Elixir"},
               2 => %{id: 2, date: "2020-10-17", title: "Eat sushi"}
             }
           }
  end

  test "add_entry/2 inserts an entry" do
    entry1 = %{date: "2020-10-16", title: "Study Elixir"}
    entry2 = %{date: "2020-10-17", title: "Eat sushi"}

    instance =
      TodoCrud.new()
      |> TodoCrud.add_entry(entry1)
      |> TodoCrud.add_entry(entry2)

    assert instance == %TodoCrud{
             auto_id: 3,
             collection: %{
               1 => %{id: 1, date: "2020-10-16", title: "Study Elixir"},
               2 => %{id: 2, date: "2020-10-17", title: "Eat sushi"}
             }
           }
  end

  test "entries/2 fetches a title for a given date" do
    entry1 = %{date: "2020-10-16", title: "Study Elixir"}
    entry2 = %{date: "2020-10-17", title: "Eat sushi"}
    entry3 = %{date: "2020-10-20", title: "Study Kubernetes"}

    instance =
      TodoCrud.new()
      |> TodoCrud.add_entry(entry1)
      |> TodoCrud.add_entry(entry2)
      |> TodoCrud.add_entry(entry3)

    assert TodoCrud.entries(instance, "2020-10-17") == [
             %{id: 2, date: "2020-10-17", title: "Eat sushi"}
           ]
  end

  test "update_entry/3 updates an entry and returns the updated TodoCrud struct" do
    entry1 = %{date: "2020-10-16", title: "Study Elixir"}

    instance =
      TodoCrud.new()
      |> TodoCrud.add_entry(entry1)
      |> TodoCrud.update_entry(1, &%{&1 | title: "Go for a walk"})

    assert instance == %TodoCrud{
             auto_id: 2,
             collection: %{1 => %{id: 1, date: "2020-10-16", title: "Go for a walk"}}
           }
  end

  test "update_entry/2 updates an entry and returns the updated TodoCrud struct" do
    entry1 = %{date: "2020-10-16", title: "Study Elixir"}

    instance =
      TodoCrud.new()
      |> TodoCrud.add_entry(entry1)
      |> TodoCrud.update_entry(%{id: 1, date: "2020-10-16", title: "Go for a walk"})

    assert instance == %TodoCrud{
             auto_id: 2,
             collection: %{1 => %{id: 1, date: "2020-10-16", title: "Go for a walk"}}
           }
  end

  test "delete_entry/2 deletes deletes an entry" do
    instance = TodoCrud.new() |> TodoCrud.add_entry(%{date: "2020-10-16", title: "Study Elixir"})

    assert instance == %TodoCrud{
             auto_id: 2,
             collection: %{1 => %{id: 1, date: "2020-10-16", title: "Study Elixir"}}
           }

    entry = instance |> TodoCrud.entries("2020-10-16") |> hd
    updated_instance = TodoCrud.delete_entry(instance, entry.id)

    assert updated_instance == %TodoCrud{
             auto_id: 2,
             collection: %{}
           }
  end
end
