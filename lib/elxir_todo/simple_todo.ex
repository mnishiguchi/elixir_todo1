defmodule ElixirTodo.SimpleTodoList do
  @moduledoc """
  ## Examples

      iex> todo_list = TodoList.new
      %{}

      iex> todo_list = todo_list |> TodoList.add_entry("2020-10-16", "Study Elixir")
      %{"2020-10-16" => ["Study Elixir"]}

      iex> TodoList.entries(todo_list, "2020-10-16")
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
  def add_entry(todo_list, date, title) do
    Map.update(
      todo_list,
      date,
      # Default value
      [title],
      # Updater function
      fn titles -> [title | titles] end
    )
  end

  @doc """
  Fetches a todo title for a given date.
  """
  def entries(todo_list, date) do
    Map.get(
      todo_list,
      date,
      # Default value
      []
    )
  end
end
