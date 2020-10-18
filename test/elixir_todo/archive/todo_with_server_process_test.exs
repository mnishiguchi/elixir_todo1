defmodule TodoWithServerProcessTest do
  use ExUnit.Case
  doctest ElixirTodo

  alias ElixirTodo.TodoWithServerProcess

  setup do
    {:ok, server_pid: TodoWithServerProcess.start()}
  end

  test "CRUD operations", %{server_pid: server_pid} do
    # Create and verify
    TodoWithServerProcess.add_entry(server_pid, %{date: "2020-10-16", title: "Study Elixir"})
    |> Kernel.==({:cast, {:add_entry, %{date: "2020-10-16", title: "Study Elixir"}}})
    |> assert

    TodoWithServerProcess.entries(server_pid, "2020-10-16")
    |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Study Elixir"}])
    |> assert

    # Update and verify
    TodoWithServerProcess.update_entry(server_pid, %{
      id: 1,
      date: "2020-10-16",
      title: "Eat sushi"
    })
    |> Kernel.==({:cast, {:update_entry, %{date: "2020-10-16", id: 1, title: "Eat sushi"}}})
    |> assert

    TodoWithServerProcess.entries(server_pid, "2020-10-16")
    |> Kernel.==([%{date: "2020-10-16", id: 1, title: "Eat sushi"}])
    |> assert

    #  Delete and verify
    assert TodoWithServerProcess.delete_entry(server_pid, 1) == {:cast, {:delete_entry, 1}}
    assert TodoWithServerProcess.entries(server_pid, "2020-10-16") == []
  end
end
