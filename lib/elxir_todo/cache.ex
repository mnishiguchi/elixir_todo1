defmodule ElixirTodo.Cache do
  use GenServer

  @doc """
  A server that creates and store `ElixirTodo.Server` instances. Multiple
  clients issue requests to the single `ElixirTodo.Cache` process.
  """

  # ---
  # The client API
  # ---

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end

  # ---
  # The server callbacks
  # ---

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_list_name}, _caller_pid, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      # That server exists in the map.
      {:ok, todo_server} ->
        {:reply, todo_server, todo_servers}

      :error ->
        {:ok, new_server} = ElixirTodo.Server.start()

        {
          :reply,
          new_server,
          todo_servers |> Map.put(todo_list_name, new_server)
        }
    end
  end
end
