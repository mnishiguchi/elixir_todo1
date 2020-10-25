defmodule ElixirTodo.ProcessRegistry do
  def start_link() do
    IO.puts("Starting #{__MODULE__}")

    # Start a unique registry.
    Registry.start_link(keys: :unique, name: __MODULE__)
  end

  # Returns a standardized via-tuple for this registry.
  def via_tuple(key) do
    {:via, Registry, {__MODULE__, key}}
  end

  # Defines a custom child spec so that this Registry can be supervised.
  def child_spec(_opts) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
