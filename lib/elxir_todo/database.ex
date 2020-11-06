defmodule ElixirTodo.Database do
  @moduledoc """
  A synchronization point of database operations. Maintains a pool of database
  workers. Actual work is delegated to ElixirTodo.DatabaseWorkers. A worker is
  chosen in a way the same key is always handled by the same worker so that we
  can avoid a race condition.
  """

  @pool_size 3

  # A custom child spec so that Database can be a supervisor.
  def child_spec(_opts) do
    pool_options = [
      name: {:local, __MODULE__},
      worker_module: ElixirTodo.DatabaseWorker,
      size: @pool_size
    ]

    db_directory = Application.fetch_env!(:elixir_todo, :db_directory)
    File.mkdir_p!(db_directory)

    worker_args = db_directory
    :poolboy.child_spec(__MODULE__, pool_options, worker_args)
  end

  def clear(db_directory) do
    File.rm_rf!(db_directory)
    File.mkdir_p!(db_directory)
  end

  def store(key, data) do
    # Invoke :poolboy.transaction/2, passing the registered name of the pool
    # manager, which will issue a checkout request to fetch a single worker.
    # Once a worker is available, the provided lambda is invoked. When the
    # lambda is finished, :poolboy .transaction/2 will return the worker to the
    # pool.
    :poolboy.transaction(
      __MODULE__,
      fn worker_id -> ElixirTodo.DatabaseWorker.store(worker_id, key, data) end
    )
  end

  def get(key) do
    :poolboy.transaction(
      __MODULE__,
      fn worker_id -> ElixirTodo.DatabaseWorker.get(worker_id, key) end
    )
  end
end
