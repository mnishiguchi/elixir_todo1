defmodule ElixirTodo.Database do
  @moduledoc """
  A synchronization point of database operations. Actual work is delegated to
  ElixirTodo.DatabaseWorkers. A worker is chosen in a way the same key is always
  handled by the same worker so that we can avoid a race condition.
  """

  # https://hexdocs.pm/elixir/GenServer.html
  use GenServer

  @process_name __MODULE__
  @db_directory "./tmp/persist/"
  @worker_count 3

  # ---
  # The client API
  # ---

  def start(db_directory \\ nil) do
    GenServer.start(__MODULE__, db_directory || @db_directory)
  end

  def stop() do
    GenServer.stop(@process_name)
  end

  def clear(db_directory) do
    File.rm_rf!(db_directory)
    File.mkdir_p!(db_directory)
  end

  def store(key, data) do
    choose_worker(key) |> ElixirTodo.DatabaseWorker.store(key, data)
  end

  def get(key) do
    choose_worker(key) |> ElixirTodo.DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    GenServer.call(@process_name, {:choose_worker, key})
  end

  # ---
  # The server callbacks
  # ---

  def init(db_directory) do
    File.mkdir_p!(db_directory)
    send(self(), :initialize_state)

    # Manually register our process instead of `GenServer.start` name option so
    # that we can be sure that `:initialize_state` is the first message.
    Process.register(self(), @process_name)

    {:ok, nil}
  end

  def handle_info(:initialize_state, _state) do
    worker_lookup = start_workers() |> IO.inspect
    {:noreply, worker_lookup}
  end

  def handle_call({:choose_worker, key}, _caller_pid, workers) do
    chosen_worker = workers |> Map.get(worker_hash_key(key)) |> IO.inspect
    {:reply, chosen_worker, workers}
  end

  def worker_hash_key(key) do
    :erlang.phash2(key, @worker_count)
  end

  # Starts as many workers as `@worker_count` and returns a zero-indexed map.
  defp start_workers() do
    for index <- 1..@worker_count, into: %{} do
      {:ok, pid} = ElixirTodo.DatabaseWorker.start(@db_directory)
      {index - 1, pid}
    end
  end
end
