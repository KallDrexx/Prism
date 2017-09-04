defmodule Prism.Handlers.EchoHandler do

  @behaviour Prism.Handler

  def init(_) do
    {:ok, []}
  end

  def input_received(context, input) do
    :ok = Prism.Handler.relay_output(context.parent_pid, input)
    {:ok, []}
  end

  def output_received(_context, _output) do
    {:ok, []}
  end

  def handle_message(_context, _message) do
    {:ok, []}
  end

end
