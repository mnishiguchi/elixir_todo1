defmodule ElixirTodo.ServerProcess do
  @moduledoc """
  The abstraction for the generic server process. It lets us easily create
  various kinds of processes that rely on the common code.
  """

  @doc """
  Accepts a module atom and spawns the process. Returns a pid.
  """
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  @doc """
  Handles a synchronous request.
  """
  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} -> response
    end
  end

  @doc """
  Handles a fire-and-forget async request.
  """
  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  # Powers the server process and maintains state.
  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller_pid} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller_pid, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end
  end
end
