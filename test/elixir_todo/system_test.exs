defmodule ElixirTodo.SystemTest do
  use ExUnit.Case

  test "system restarts without leaving behind dangling processes" do
    ElixirTodo.Cache.server_process("Bob's")
    process_count1 = :erlang.system_info(:process_count)

    Application.stop(ElixirTodo.Application)

    ElixirTodo.Cache.server_process("Bob's")
    process_count2 = :erlang.system_info(:process_count)

    assert process_count1 == process_count2
  end
end
