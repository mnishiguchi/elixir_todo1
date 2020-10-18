defmodule ElixirTodo.KeyValueStore do
  @moduledoc """
  A key value store that is build with ServerProcess module.

  Examples:

      iex> pid = ServerProcess.start(KeyValueStore)
      #PID<0.201.0>
      iex> ServerProcess.call(pid, {:put, :some_key, :some_value})
      :ok
      iex> ServerProcess.call(pid, {:get, :some_key})
      :some_value

      iex> pid = KeyValueStore.start
      #PID<0.218.0>
      iex> pid |> KeyValueStore.put("name", "Masa")
      :ok
      iex> pid |> KeyValueStore.get("name")
      "Masa"

  """

  alias ElixirTodo.ServerProcess

  # ---
  # The client API
  # ---

  def start do
    ServerProcess.start(__MODULE__)
  end

  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  # ---
  # The server callbacks
  # ---

  # Initialize the server state.
  def init, do: Map.new()

  # Handles the put request.
  def handle_cast({:put, key, value}, state) do
    Map.put(state, key, value)
  end

  # Handles the get request.
  def handle_call({:get, key}, state) do
    {Map.get(state, key), state}
  end
end
