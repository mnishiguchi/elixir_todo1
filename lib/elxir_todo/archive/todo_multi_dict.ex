defmodule ElixirTodo.TodoMultiDict do
  alias ElixirTodo.MultiDict

  def new do
    MultiDict.new()
  end

  def add_entry(todo_list, date, title) do
    MultiDict.add(todo_list, date, title)
  end

  def entries(todo_list, date) do
    MultiDict.get(todo_list, date)
  end
end
