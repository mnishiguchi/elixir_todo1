defmodule ElixirTodo.DatabaseWorker do
  @moduledoc """
  Performs read/write operations on a simple disk-based data persistence storage.

  The discovery of the pid is performed by the pool, so we do not need to
  register the workers.
  """

  # https://hexdocs.pm/elixir/GenServer.html
  use GenServer

  @doc """
  - db_directory - a path to db directory
  """
  def start_link(db_directory) when is_binary(db_directory) do
    IO.puts("Starting #{__MODULE__}:#{db_directory}")
    GenServer.start_link(__MODULE__, db_directory)
  end

  def stop(pid) when is_pid(pid) do
    GenServer.stop(pid)
  end

  def store(pid, key, data) when is_pid(pid) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) when is_pid(pid) do
    GenServer.call(pid, {:get, key})
  end

  # ---
  # The server callbacks
  # ---

  def init(db_directory) do
    {:ok, db_directory}
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
