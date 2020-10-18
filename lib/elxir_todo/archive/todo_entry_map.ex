defmodule ElixirTodo.TodoEntryMap do
  @moduledoc """
  ## Examples

      iex> todo_list = TodoEntryMap.new
      %{}

      iex> todo_list = todo_list |> TodoEntryMap.add_entry(%{date: "2020-10-16", title: "Study Elixir"})
      %{"2020-10-16" => [%{date: "2020-10-16", title: "Study Elixir"}]}

      iex> TodoEntryMap.entries(todo_list, "2020-10-16")
      [%{date: "2020-10-16", title: "Study Elixir"}]

  """

  alias ElixirTodo.MultiDict

  def new do
    MultiDict.new()
  end

  def add_entry(todo_list, %{date: date, title: _title} = entry) do
    MultiDict.add(todo_list, date, entry)
  end

  def entries(todo_list, date) do
    MultiDict.get(todo_list, date)
  end
end
