defmodule ElixirTodo.Metrics do
  @moduledoc """
  This was a simple way of implementing a periodic job in your system, without
  needing to run multiple OS processes and use external schedulers such as cron.
  """

  use Task

  @interval :timer.seconds(10)

  def start_link(_args) do
    Task.start_link(fn -> loop() end)
  end

  defp loop() do
    Process.sleep(@interval)
    IO.inspect(collect_metrics())
    loop()
  end

  defp collect_metrics() do
    [
      memory_usage: :erlang.memory(:total),
      process_count: :erlang.system_info(:process_count)
    ]
  end
end
