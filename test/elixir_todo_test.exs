defmodule ElixirTodoTest do
  use ExUnit.Case
  doctest ElixirTodo

  test "greets the world" do
    assert ElixirTodo.hello() == :world
  end
end
