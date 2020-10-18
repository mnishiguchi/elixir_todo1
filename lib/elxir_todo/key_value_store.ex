defmodule ElixirTodo.KeyValueStore do
  @moduledoc """
  A key value store that is build with GenServer module.

  ## Examples:

      iex> {:ok, pid} = KeyValueStore.start
      #PID<0.218.0>
      iex> pid |> KeyValueStore.put("name", "Masa")
      :ok
      iex> pid |> KeyValueStore.get("name")
      "Masa"

  """

  # https://hexdocs.pm/elixir/GenServer.html
  use GenServer

  # ---
  # The client API
  # ---

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # ---
  # The server callbacks
  # ---

  # Initialize the server state.
  @impl true
  def init(_) do
    # :timer.send_interval(5000, :cleanup)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:cleanup, state) do
    IO.puts("performing cleanup...")
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state), do: {:noreply, state}

  # Handles the put request.
  @impl true
  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  # Handles the get request.
  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Map.get(state, key), state}
  end
end
