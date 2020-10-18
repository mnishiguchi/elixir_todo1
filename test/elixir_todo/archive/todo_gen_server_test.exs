defmodule TodoGenServerTest do
  use ExUnit.Case
  doctest ElixirTodo

  alias ElixirTodo.TodoGenServer

  setup do
    {:ok, _pid} = TodoGenServer.start()
    # IO.puts("\nServer started")

    on_exit(fn ->
      :ok = TodoGenServer.stop()
      # IO.puts("Server stopped")
    end)

    :ok
  end

  describe "add_entry/2" do
    test "inserts an entry" do
      TodoGenServer.add_entry(%{date: "2020-10-16", title: "Study Elixir"})
      |> Kernel.==(:ok)
      |> assert

      TodoGenServer.entries("2020-10-16")
      |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Study Elixir"}])
      |> assert
    end
  end

  describe "update_entry/2" do
    setup do
      :ok = TodoGenServer.add_entry(%{date: "2020-10-16", title: "Study Elixir"})
    end

    test "updates an entry" do
      TodoGenServer.update_entry(%{id: 1, date: "2020-10-16", title: "Eat sushi"})
      |> Kernel.==(:ok)
      |> assert

      TodoGenServer.entries("2020-10-16")
      |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Eat sushi"}])
      |> assert
    end
  end

  describe "delete_entry/2" do
    setup do
      :ok = TodoGenServer.add_entry(%{date: "2020-10-16", title: "Study Elixir"})
    end

    test "delete an entry" do
      assert TodoGenServer.delete_entry(1) == :ok
      assert TodoGenServer.entries("2020-10-16") == []
    end
  end
end
