defmodule ElixirTodo.DatabaseWorker do
  @moduledoc """
  Performs read/write operations on a simple disk-based data persistence storage.
  """

  # https://hexdocs.pm/elixir/GenServer.html
  use GenServer

  # ---
  # The client API
  # ---

  def start(db_directory) do
    IO.puts "Starting #{__MODULE__}"
    GenServer.start(__MODULE__, db_directory)
  end

  def stop(worker_pid) do
    GenServer.stop(worker_pid)
  end

  def clear(db_directory) do
    File.rm_rf!(db_directory)
  end

  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(worker_pid, {:get, key})
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
