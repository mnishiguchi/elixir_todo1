defmodule ElixirTodo.Database do
  @moduledoc """
  A simple disk-based data persistence storage.
  """

  # https://hexdocs.pm/elixir/GenServer.html
  use GenServer

  # ---
  # The client API
  # ---

  @server_name __MODULE__
  @db_directory "./tmp/persist/"

  def start(db_directory \\ nil) do
    # The process is locally registered under an alias, which keeps things
    # simple and relieves us from passing around the pid. A downside is that we
    # can run only one instance of the database process.
    GenServer.start(__MODULE__, db_directory || @db_directory, name: @server_name)
  end

  def stop() do
    GenServer.stop(@server_name)
  end

  def clear(db_directory) do
    File.rm_rf!(db_directory)
  end

  def store(key, data) do
    GenServer.cast(@server_name, {:store, key, data})
  end

  def get(key) do
    GenServer.call(@server_name, {:get, key})
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
    spawn(fn ->
      file_path(db_directory, key) |> save_data(data)
    end)

    {:noreply, db_directory}
  end

  def handle_call({:get, key}, caller_pid, db_directory) do
    # The problem with this approach is that concurrency is unbound. If you have
    # 100,000 simultaneous clients, then you’ll issue that many concurrent I/O
    # operations, which may negatively affect the entire system.
    spawn(fn ->
      data = file_path(db_directory, key) |> fetch_data()
      GenServer.reply(caller_pid, data)
    end)

    {:noreply, db_directory}
  end

  defp file_path(db_directory, key) do
    "#{db_directory}/#{key}"
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
