defmodule ElixirTodo.Cache do
  use GenServer

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

  # ---
  # The client API
  # ---

  # Link to the caller process. It is required if we want to run the process
  # under a supervisor. Also the process needs to be registered under a local
  # alias instead of passing a pid around. When a process crashe, the supervisor
  # will replace it with a new process.
  def start_link(_opts) do
    IO.puts("Starting #{__MODULE__}")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(todo_list_name) do
    GenServer.call(__MODULE__, {:server_process, todo_list_name})
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
