defmodule Support.TestIncrementalHandler do
  @moduledoc false

  @behaviour Prism.Handler
  require Logger

  def init(_) do
    {:ok, []}
  end

  def input_received(context = %Prism.HandlerContext{}, input) do
    case context.child_pid do
      pid when is_pid(pid) -> :ok = Prism.Handler.relay_input(pid, input + 1)
      nil -> :ok
    end

    {:ok, []}
  end

  def output_received(context = %Prism.HandlerContext{}, output) do
    case context.parent_pid do
      pid when is_pid(pid) -> :ok = Prism.Handler.relay_output(pid, output + 1)
      nil -> :ok
    end

    {:ok, []}
  end
end