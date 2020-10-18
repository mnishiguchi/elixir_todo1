defmodule ElixirTodo.List do
  # auto_id - the id value that is assigned to a new entry, initially 1.
  # collection - the collection of collection, initially an empty map.
  defstruct auto_id: 1, collection: %{}

  alias ElixirTodo.List

  @doc """
  A constructror that returns a new instance of List struct.
  """
  def new(entries \\ []) do
    Enum.reduce(
      entries,
      # Initial accumulator value
      %List{},
      # Updater function
      fn entry, instance_acc -> add_entry(instance_acc, entry) end
    )
  end

  @doc """
  A reducer that updates a List struct with a given entry.
  """
  def add_entry(
        %List{collection: collection, auto_id: auto_id} = instance,
        %{date: _date, title: _title} = entry
      ) do
    # Set the id for the entry being added.
    new_entry = put_in(entry[:id], auto_id)

    # Add the new entry to the collection and increment the `auto_id` field.
    instance
    |> Map.put(:collection, put_in(collection[auto_id], new_entry))
    |> Map.put(:auto_id, auto_id + 1)
  end

  @doc """
  A query that fetches collection for a given date.
  """
  def entries(
        %List{collection: collection} = _instance,
        date
      ) do
    # Both trensformations happens in a single pass through the input collection
    # because we use Stream for the first transformer function.
    collection
    |> Stream.filter(fn {_id, entry} -> entry.date == date end)
    |> Enum.map(fn {_id, entry} -> entry end)
  end

  @doc """
  A reducer that updates an entry in the collection.
  """
  def update_entry(
        %List{} = instance,
        %{id: id} = entry
      ) do
    update_entry(instance, id, fn _ -> entry end)
  end

  def update_entry(
        %List{collection: collection} = instance,
        entry_id,
        updater_fn \\ fn entry -> entry end
      )
      when is_number(entry_id) do
    case collection[entry_id] do
      nil ->
        instance

      entry ->
        # Pattern match to assert the correct data returned from the updater:
        # - The entry should be a map.
        # - The entry ID should be unchanged after updated.
        entry_id = entry.id
        updated_entry = %{id: ^entry_id} = updater_fn.(entry)

        instance |> Map.put(:collection, put_in(collection[entry_id], updated_entry))
    end
  end

  @doc """
  A reducer that removes an entry in the collection.
  """
  def delete_entry(
        %List{collection: collection} = instance,
        id
      )
      when is_number(id) do
    instance |> Map.put(:collection, Map.delete(collection, id))
  end
end
