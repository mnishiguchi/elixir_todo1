defmodule ElixirTodo.SystemTest do
  use ExUnit.Case

  test "system restarts without leaving behind dangling processes" do
    start_system()

    ElixirTodo.Cache.server_process("Bob's")
    process_count1 = :erlang.system_info(:process_count)

    terminate_system()

    ElixirTodo.Cache.server_process("Bob's")
    process_count2 = :erlang.system_info(:process_count)

    assert process_count1 == process_count2
  end

  defp start_system do
    {:ok, system} = ElixirTodo.System.start_link()
    Process.sleep(1)
  end

  defp terminate_system do
    Process.exit(Process.whereis(ElixirTodo.Cache), :kill)
    Process.sleep(1)
  end
end
