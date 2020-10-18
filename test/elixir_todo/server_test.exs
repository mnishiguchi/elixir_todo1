defmodule ServerTest do
  use ExUnit.Case
  doctest ElixirTodo

  setup do
    {:ok, _pid} = ElixirTodo.Server.start()
    # IO.puts("\nServer started")

    on_exit(fn ->
      :ok = ElixirTodo.Server.stop()
      # IO.puts("Server stopped")
    end)

    :ok
  end

  describe "add_entry/2" do
    test "inserts an entry" do
      ElixirTodo.Server.add_entry(%{date: "2020-10-16", title: "Study Elixir"})
      |> Kernel.==(:ok)
      |> assert

      ElixirTodo.Server.entries("2020-10-16")
      |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Study Elixir"}])
      |> assert
    end
  end

  describe "update_entry/2" do
    setup do
      :ok = ElixirTodo.Server.add_entry(%{date: "2020-10-16", title: "Study Elixir"})
    end

    test "updates an entry" do
      ElixirTodo.Server.update_entry(%{id: 1, date: "2020-10-16", title: "Eat sushi"})
      |> Kernel.==(:ok)
      |> assert

      ElixirTodo.Server.entries("2020-10-16")
      |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Eat sushi"}])
      |> assert
    end
  end

  describe "delete_entry/2" do
    setup do
      :ok = ElixirTodo.Server.add_entry(%{date: "2020-10-16", title: "Study Elixir"})
    end

    test "delete an entry" do
      assert ElixirTodo.Server.delete_entry(1) == :ok
      assert ElixirTodo.Server.entries("2020-10-16") == []
    end
  end
end
