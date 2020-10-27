defmodule ElixirTodo.Server do
  @moduledoc """
  Keeps a single instance of the Todo.List abstraction.
  A server that manages a given todo-list. Multiple clients communicate with
  multiple `ElixirTodo.Server` processes. There is an added benefit to the
  sequential nature of processes. Because a process runs only one request at a
  time, its internal state is consistent. We know there cannot be multiple
  simultaneous updates of the process state, which makes race conditions in a
  single process impossible. Each process serves as a synchronization point.
  """

  # Does not restart on termination.
  # Servers are started on demand, so when a user tries to interact with a to-do
  # list, if the server process isn’t running, it will be started. If a to-do
  # list server crashes, it will be started on the next use, so there’s no need
  # to restart it automatically.
  use GenServer, restart: :temporary

  defp via_tuple(todo_list_name) do
    ElixirTodo.ProcessRegistry.via_tuple({__MODULE__, todo_list_name})
  end

  # ---
  # The client API
  # ---

  def start_link(todo_list_name) when is_binary(todo_list_name) do
    IO.puts "Starting #{__MODULE__}:#{todo_list_name}"
    GenServer.start_link(__MODULE__, todo_list_name, name: via_tuple(todo_list_name))
  end

  def stop(pid) do
    GenServer.stop(pid)
  end

  def add_entry(pid, %{date: _date, title: _title} = entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def update_entry(pid, %{id: _id} = entry) do
    GenServer.cast(pid, {:update_entry, entry})
  end

  def delete_entry(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  # ---
  # The server callbacks
  # ---

  # Initialize the server state.
  def init(todo_list_name) do
    send(self(), :initialize_state)
    {:ok, {todo_list_name, nil}}
  end

  def handle_info(:initialize_state, {todo_list_name, _} = _state) do
    # Important: This assumes ElixirTodo.Database is already running.
    todo_list = ElixirTodo.Database.get(todo_list_name) || ElixirTodo.List.new()
    {:noreply, {todo_list_name, todo_list}}
  end

  # Fetches collection for a given date. Returns matching entries.
  def handle_call({:entries, date}, _caller_pid, {_todo_list_name, todo_list} = state) do
    matched_entries = todo_list |> ElixirTodo.List.entries(date)
    {:reply, matched_entries, state}
  end

  # Updates a ElixirTodo.Server struct with a given entry. Returns new state.
  def handle_cast({:add_entry, entry}, {todo_list_name, todo_list} = _state) do
    updated_todo_list = %ElixirTodo.List{} = todo_list |> ElixirTodo.List.add_entry(entry)
    ElixirTodo.Database.store(todo_list_name, updated_todo_list)
    {:noreply, {todo_list_name, updated_todo_list}}
  end

  # Updates an entry in the collection. Returns new state.
  def handle_cast({:update_entry, entry}, {todo_list_name, todo_list} = _state) do
    updated_todo_list = %ElixirTodo.List{} = todo_list |> ElixirTodo.List.update_entry(entry)
    {:noreply, {todo_list_name, updated_todo_list}}
  end

  # Deletes an entry in the collection. Returns new state.
  def handle_cast({:delete_entry, id}, {todo_list_name, todo_list} = _state) when is_number(id) do
    updated_todo_list = %ElixirTodo.List{} = todo_list |> ElixirTodo.List.delete_entry(id)
    {:noreply, {todo_list_name, updated_todo_list}}
  end
end
