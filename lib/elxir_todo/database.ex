defmodule ElixirTodo.Database do
  @moduledoc """
  A synchronization point of database operations. Maintains a pool of database
  workers. Actual work is delegated to ElixirTodo.DatabaseWorkers. A worker is
  chosen in a way the same key is always handled by the same worker so that we
  can avoid a race condition.
  """

  @default_db_directory "./tmp/persist/"
  @pool_size 3

  # A custom child spec so that Database can be a supervisor.
  def child_spec(_opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]},
      type: :supervisor
    }
  end

  # ---
  # The client API
  # ---

  # Optionally accepts the `db_directory` option for testing.
  def start_link(opts) when is_list(opts) do
    {:ok, db_directory} = opts |> Keyword.get(:db_directory, nil) |> setup_db_directory()

    IO.puts("Starting #{__MODULE__}:#{db_directory}")
    children = 1..@pool_size |> Enum.map(fn worker_id -> worker_spec(db_directory, worker_id) end)
    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp worker_spec(db_directory, worker_id) do
    # A unique ID is necessary for each worker because DatabaseWorker's default
    # child_spec/1 has __MODULE__ in the :id field.
    Supervisor.child_spec(
      {ElixirTodo.DatabaseWorker, [db_directory: db_directory, worker_id: worker_id]},
      id: worker_id
    )
  end

  defp setup_db_directory(path) do
    db_directory =
      if is_blank?(path),
        do: @default_db_directory,
        else: path

    :ok = File.mkdir_p!(db_directory)
    {:ok, db_directory}
  end

  defp is_blank?(nil), do: true
  defp is_blank?([]), do: true
  defp is_blank?(%{}), do: true
  defp is_blank?(value) when is_binary(value), do: String.trim(value) == ""

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

  # Returns a worker id that is used for finding a worker.
  defp choose_worker(key) do
    # Add one to convert 0-based index to 1-based
    :erlang.phash2(key, @pool_size) + 1
  end
end
