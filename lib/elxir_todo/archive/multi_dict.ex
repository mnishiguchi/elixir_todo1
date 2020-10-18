defmodule ElixirTodo.MultiDict do
  @moduledoc """
  ## Examples

      iex> todo_list = MultiDict.new
      %{}

      iex> todo_list = todo_list |> MultiDict.add_entry("2020-10-16", "Study Elixir")
      %{"2020-10-16" => ["Study Elixir"]}

      iex> MultiDict.entries(todo_list, "2020-10-16")
      ["Study Elixir"]

  """

  @doc """
  Instantiates a new Map.
  """
  def new do
    Map.new()
  end

  @doc """
  Adds a new entry to a todo list.
  """
  def add(todo_list, key, value) do
    Map.update(
      todo_list,
      key,
      # Default value
      [value],
      # Updater function
      fn values -> [value | values] end
    )
  end

  @doc """
  Fetches a todo value for a given key.
  """
  def get(todo_list, key) do
    Map.get(
      todo_list,
      key,
      # Default value
      []
    )
  end
end
