defmodule ElixirTodo.Cache do
  @moduledoc """
  The system entry point that maintains a collection of `ElixirTodo.Server`
  instances and is responsible for their creation and retrieval. All clients
  issue requests to the single `ElixirTodo.Cache` process.

  ## Examples

      Supervisor.start_link [TodoCache], strategy: :one_for_one
      # Starting Elixir.ElixirTodo.Cache
      # Starting Elixir.ElixirTodo.Database
      # Starting Elixir.ElixirTodo.DatabaseWorker
      # Starting Elixir.ElixirTodo.DatabaseWorker
      # Starting Elixir.ElixirTodo.DatabaseWorker
      # {:ok, #PID<0.219.0>}

      bob = TodoCache.server_process "Bob"
      # Starting Elixir.ElixirTodo.Server:Bob
      # #PID<0.222.0>
      # #PID<0.226.0>

      Process.whereis(TodoCache)
      # #PID<0.220.0>

      cache = Process.whereis TodoCache
      # #PID<0.220.0>

      Process.exit(cache, :kill)
      # Starting Elixir.ElixirTodo.Cache
      # Starting Elixir.ElixirTodo.Database

  """

  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]},
      type: :supervisor
    }
  end

  # ---
  # The client API
  # ---

  # Link to the caller process. It is required if we want to run the process
  # under a supervisor. Also the process needs to be registered under a local
  # alias instead of passing a pid around. When a process crashe, the supervisor
  # will replace it with a new process.
  def start_link(_opts) do
    IO.puts("Starting #{__MODULE__}")

    # Start the supervisor process here but no children are specified at this
    # point. The process is registered under a local name, which makes it easy
    # to interact with that process and ask it to start a child.
    DynamicSupervisor.start_link(
      name: __MODULE__,
      strategy: :one_for_one
    )
  end

  def server_process(todo_list_name) do
    # The way start_child is used here is not very efficient. Every time we want
    # to work with a to-do list, we issue a request to the supervisor, so the
    # supervisor process can become a bottleneck. We will improve it later.
    case start_child(todo_list_name) do
      {:ok, pid} -> pid
      # We tried to start the server, but it was already running. That’s fine.
      # We have the pid of the server, and we can interact with it.
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp start_child(todo_list_name) do
    # Ask the supervisor named ElixirTodo.Cache to start a child by involking
    # `ElixirTodo.Server.start_link(todo_list_name)`.
    # DynamicSupervisor.start_child/2 is a cross-process synchronous call. A
    # request is sent to the supervisor process, which then starts the child. If
    # multiple client processes simultaneously try to start a child under the
    # same supervisor, the requests will be serialized.
    DynamicSupervisor.start_child(
      __MODULE__,
      {ElixirTodo.Server, todo_list_name}
    )
  end

  # ---
  # The server callbacks
  # ---

  def init(_) do
    # A map of a todo list name to PID; initially blank.
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _caller_pid, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      # That server exists in the map.
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = ElixirTodo.Server.start_link(todo_list_name)

        {
          :reply,
          new_server,
          todo_servers |> Map.put(todo_list_name, new_server)
        }
    end
  end
end
