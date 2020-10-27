defmodule ElixirTodo.DatabaseWorker do
  @moduledoc """
  Performs read/write operations on a simple disk-based data persistence storage.
  """

  # https://hexdocs.pm/elixir/GenServer.html
  use GenServer

  # This is used as a process name. We do not need to keep track of the pids.
  defp via_tuple(worker_id) do
    ElixirTodo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end

  # ---
  # The client API
  # ---

  @doc """
  - db_directory - a path to db directory
  - worker_id - a unique number that identifies a worker
  """
  def start_link(db_directory: db_directory, worker_id: worker_id)
      when is_binary(db_directory)
      when is_number(worker_id) do
    IO.puts("Starting #{__MODULE__}:#{db_directory}:#{worker_id}")

    GenServer.start_link(
      __MODULE__,
      db_directory,
      name: via_tuple(worker_id)
    )
  end

  def stop(worker_id) do
    GenServer.stop(via_tuple(worker_id))
  end

  def clear(db_directory) do
    File.rm_rf!(db_directory)
  end

  def store(worker_id, key, data) do
    GenServer.cast(via_tuple(worker_id), {:store, key, data})
  end

  def get(worker_id, key) do
    GenServer.call(via_tuple(worker_id), {:get, key})
  end

  # ---
  # The server callbacks
  # ---

  def init(db_directory) do
    {:ok, ensure_directory(db_directory)}
  end

  defp ensure_directory(directory) do
    File.mkdir_p!(directory)
    directory
  end

  def handle_cast({:store, key, data}, db_directory) do
    file_path(db_directory, key) |> save_data(data)
    {:noreply, db_directory}
  end

  def handle_call({:get, key}, caller_pid, db_directory) do
    data = file_path(db_directory, key) |> fetch_data()
    GenServer.reply(caller_pid, data)
    {:noreply, db_directory}
  end

  defp file_path(db_directory, key) do
    Path.join(db_directory, to_string(key))
  end

  defp save_data(path, data) do
    File.write!(path, :erlang.term_to_binary(data))
  end

  defp fetch_data(path) do
    case File.read(path) do
      {:ok, contents} -> :erlang.binary_to_term(contents)
      _ -> nil
    end
  end
end
