defmodule Prism.Handlers.ReverseTextHandler do

  @behaviour Prism.Handler

  def init(_) do
    {:ok, []}
  end

  def input_received(context, input) do
    input = String.trim(input)
    |> String.reverse()

    test = self()
    :ok = Prism.Handler.relay_input(context.child_pid, input)
    {:ok, []}
  end

  def output_received(context, output) do
    output = String.trim(output) <> "\r\n"
    :ok = Prism.Handler.relay_output(context.parent_pid, output)
    {:ok, []}
  end

  def handle_message(_context, _message) do
    {:ok, []}
  end


end
