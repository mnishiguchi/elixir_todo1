defmodule ElixirTodo.System do
  @moduledoc """
  A wrapper around a supervisor.

  By linking a group of inter- dependent processes, you can ensure that the
  crash of one process takes down its dependencies as well.
  This is a proper error-recovery approach: you can detect an error in any part
  of the system and recover from it without leaving behind dangling processes.
  On the down- side, you’re allowing errors to have a wide impact.

  This is far from perfect, and you’ll make improvements later.

  ## Examples

      {:ok, system} = ElixirTodo.System.start_link()
      # {:ok, #PID<0.249.0>}
      bobs = ElixirTodo.Cache.server_process("Bob's")
      :erlang.system_info(:process_count)
      # #PID<0.253.0>
      # #PID<0.256.0>
      Process.exit(Process.whereis(ElixirTodo.Cache), :kill)
      # 109
      bobs = ElixirTodo.Cache.server_process("Bob's")
      # #PID<0.263.0>
      # #PID<0.265.0>
      :erlang.system_info(:process_count)
      # 109 #<- Make sure this is unchanged.

  """

  use Supervisor

  # ---
  # The client API
  # ---

  def start_link() do
    Supervisor.start_link(__MODULE__, nil)
  end

  # ---
  # The server callbacks
  # ---

  def init(_) do
    # Child processes are started synchronously.
    # Always make sure our init/1 functions run quickly.
    Supervisor.init(
      [
        ElixirTodo.Metrics,
        ElixirTodo.ProcessRegistry,
        ElixirTodo.Database,
        ElixirTodo.Cache
      ],
      strategy: :one_for_one
    )
  end
end
