defmodule Support.TestEndpointHandler do
  @moduledoc false
  
  @behaviour Prism.Handler

  defmodule State do
    defstruct event_handler_pid: nil
  end

  def init(event_handler_pid) do
    state = %State{event_handler_pid: event_handler_pid}
    {:ok, state}
  end

  def input_received(context = %Prism.HandlerContext{}, input) do
    case context.state.event_handler_pid do
      pid when is_pid(pid) -> send(context.state.event_handler_pid, {:input_received, input})
      nil -> :ok
    end

    {:ok, []}
  end

  def output_received(context = %Prism.HandlerContext{}, output) do
    case context.state.event_handler_pid do
      pid when is_pid(pid) -> send(context.state.event_handler_pid, {:output_received, output})
      nil -> :ok
    end

    {:ok, []}
  end

  def handle_message(context, _message) do
    {:ok, context.state}
  end

end
