defmodule ElixirTodo.Application do
  use Application

  def start(_, _) do
    # Starting the application is as simple as starting the top-level supervisor.
    ElixirTodo.System.start_link()
  end
end
