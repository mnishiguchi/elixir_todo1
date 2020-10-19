defmodule ElixirTodo.ServerTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = ElixirTodo.Server.start("test todo list")
    # IO.puts("\nServer started")

    on_exit(fn ->
      :ok = ElixirTodo.Server.stop(pid)
      # IO.puts("Server stopped")
    end)

    {:ok, pid: pid}
  end

  describe "add_entry/2" do
    test "inserts an entry", %{pid: pid} do
      ElixirTodo.Server.add_entry(pid, %{date: "2020-10-16", title: "Study Elixir"})
      |> Kernel.==(:ok)
      |> assert

      ElixirTodo.Server.entries(pid, "2020-10-16")
      |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Study Elixir"}])
      |> assert
    end
  end

  describe "update_entry/2" do
    setup(%{pid: pid}) do
      :ok = ElixirTodo.Server.add_entry(pid, %{date: "2020-10-16", title: "Study Elixir"})
    end

    test "updates an entry" , %{pid: pid}do
      ElixirTodo.Server.update_entry(pid, %{id: 1, date: "2020-10-16", title: "Eat sushi"})
      |> Kernel.==(:ok)
      |> assert

      ElixirTodo.Server.entries(pid, "2020-10-16")
      |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Eat sushi"}])
      |> assert
    end
  end

  describe "delete_entry/2" do
    setup(%{pid: pid}) do
      :ok = ElixirTodo.Server.add_entry(pid, %{date: "2020-10-16", title: "Study Elixir"})
    end

    test "delete an entry", %{pid: pid} do
      assert ElixirTodo.Server.delete_entry(pid, 1) == :ok
      assert ElixirTodo.Server.entries(pid, "2020-10-16") == []
    end
  end
end
