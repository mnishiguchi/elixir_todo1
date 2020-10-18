defmodule ElixirTodo.Server do
  @moduledoc """
  A server that manages a given todo-list. Multiple clients communicate with
  multiple `ElixirTodo.Server` processes. There is an added benefit to the
  sequential nature of processes. Because a process runs only one request at a
  time, its internal state is consistent. We know there cannot be multiple
  simultaneous updates of the process state, which makes race conditions in a
  single process impossible. Each process serves as a synchronization point.
  """

  # auto_id - the id value that is assigned to a new entry, initially 1.
  # collection - the collection of collection, initially an empty map.
  defstruct auto_id: 1, collection: %{}

  use GenServer

  # ---
  # The client API
  # ---

  def start do
    GenServer.start(__MODULE__, nil)
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
  @impl true
  def init(pid) do
    {:ok, %ElixirTodo.Server{}}
  end

  # Fetches collection for a given date. Returns matching entries.
  @impl true
  def handle_call(
        {:entries, date},
        _caller_pid,
        %ElixirTodo.Server{collection: collection} = state
      ) do
    # Both trensformations happens in a single pass through the input collection
    # because we use Stream for the first transformer function.
    entries =
      collection
      |> Stream.filter(fn {_id, entry} -> entry.date == date end)
      |> Enum.map(fn {_id, entry} -> entry end)

    {:reply, entries, state}
  end

  # Updates a ElixirTodo.Server struct with a given entry. Returns new state.
  @impl true
  def handle_cast(
        {:add_entry, entry},
        %ElixirTodo.Server{collection: collection, auto_id: auto_id} = state
      ) do
    # Set the id for the entry being added.
    new_entry = put_in(entry[:id], auto_id)

    # Add the new entry to the collection and increment the `auto_id` field.
    {
      :noreply,
      state
      |> Map.put(:collection, put_in(collection[auto_id], new_entry))
      |> Map.put(:auto_id, auto_id + 1)
    }
  end

  # Updates an entry in the collection. Returns new state.
  @impl true
  def handle_cast(
        {:update_entry, entry},
        %ElixirTodo.Server{collection: collection} = state
      ) do
    %{id: entry_id} = entry

    case collection[entry_id] do
      nil ->
        {:noreply, state}

      _found ->
        {:noreply, state |> Map.put(:collection, put_in(collection[entry_id], entry))}
    end
  end

  # Deletes an entry in the collection. Returns new state.
  @impl true
  def handle_cast(
        {:delete_entry, id},
        %ElixirTodo.Server{collection: collection} = state
      )
      when is_number(id) do
    {:noreply, state |> Map.put(:collection, Map.delete(collection, id))}
  end
end
