defmodule ElixirTodo.TodoWithServerProcess do
  # auto_id - the id value that is assigned to a new entry, initially 1.
  # collection - the collection of collection, initially an empty map.
  defstruct auto_id: 1, collection: %{}

  @moduledoc """
  ## Examples

      iex> pid = TodoWithServerProcess.start()
      #PID<0.209.0>

      iex> pid |> TodoWithServerProcess.add_entry(%{date: "2020-10-18", title: "Study Elixir"})
      {:cast, {:add_entry, %{date: "2020-10-18", title: "Study Elixir"}}}

      iex> pid |> TodoWithServerProcess.entries("2020-10-18")
      [%{date: "2020-10-18", id: 1, title: "Study Elixir"}]

      iex> pid |> TodoWithServerProcess.update_entry(%{id: 1, date: "2020-10-18", title: "Eat soba"})
      {:cast, {:update_entry, %{date: "2020-10-18", id: 1, title: "Eat soba"}}}

      iex> pid |> TodoWithServerProcess.delete_entry(1)
      {:cast, {:delete_entry, 1}}

      iex> pid |> TodoWithServerProcess.entries("2020-10-18")
      []
  """

  alias ElixirTodo.TodoWithServerProcess
  alias ElixirTodo.ServerProcess

  # ---
  # The client API
  # ---

  def start do
    ServerProcess.start(__MODULE__)
  end

  def add_entry(pid, %{date: _date, title: _title} = entry) do
    ServerProcess.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    ServerProcess.call(pid, {:entries, date})
  end

  def update_entry(pid, %{id: _id} = entry) do
    ServerProcess.cast(pid, {:update_entry, entry})
  end

  def delete_entry(pid, entry_id) do
    ServerProcess.cast(pid, {:delete_entry, entry_id})
  end

  # ---
  # The server callbacks
  # ---

  # Initialize the server state.
  def init, do: %TodoWithServerProcess{}

  # Fetches collection for a given date. Returns matching entries.
  def handle_call(
        {:entries, date},
        %TodoWithServerProcess{collection: collection} = state
      ) do
    # Both trensformations happens in a single pass through the input collection
    # because we use Stream for the first transformer function.
    entries =
      collection
      |> Stream.filter(fn {_id, entry} -> entry.date == date end)
      |> Enum.map(fn {_id, entry} -> entry end)

    {entries, state}
  end

  # Updates a TodoWithServerProcess struct with a given entry. Returns new state.
  def handle_cast(
        {:add_entry, entry},
        %TodoWithServerProcess{collection: collection, auto_id: auto_id} = state
      ) do
    # Set the id for the entry being added.
    new_entry = put_in(entry[:id], auto_id)

    # Add the new entry to the collection and increment the `auto_id` field.
    state
    |> Map.put(:collection, put_in(collection[auto_id], new_entry))
    |> Map.put(:auto_id, auto_id + 1)
  end

  # Updates an entry in the collection. Returns new state.
  def handle_cast(
        {:update_entry, entry},
        %TodoWithServerProcess{collection: collection} = state
      ) do
    %{id: entry_id} = entry

    case collection[entry_id] do
      nil ->
        state

      _found ->
        state |> Map.put(:collection, put_in(collection[entry_id], entry))
    end
  end

  # Deletes an entry in the collection. Returns new state.
  def handle_cast(
        {:delete_entry, id},
        %TodoWithServerProcess{collection: collection} = state
      )
      when is_number(id) do
    state |> Map.put(:collection, Map.delete(collection, id))
  end
end
