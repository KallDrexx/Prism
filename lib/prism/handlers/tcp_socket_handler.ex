defmodule Prism.Handlers.TcpSocketHandler do
  @moduledoc """
  Handler that relays input and output to/from a TCP socket
  """

  require Logger
  @behaviour Prism.Handler

  defmodule State do
    @moduledoc false

    defstruct transport: nil,
              socket: nil,
              socket_options: nil
  end

  def init([transport, socket, socket_options]) do
    state = %State{
      transport: transport,
      socket: socket,
      socket_options: socket_options
    }

    _ = state.transport.setopts(state.socket, state.socket_options)

    {:ok, state}
  end

  def input_received(context, _input) do
    # Not expecting input from something other than sockets
    {:ok, context.state}
  end

  def output_received(context, output) do
    :ok = context.state.transport.send(context.state.socket, output)
    {:ok, context.state}
  end

  def handle_message(context, {:tcp, _, data}) do
    :ok = Prism.Handler.relay_input(context.child_pid, data)
    state = context.state
    _ = state.transport.setopts(state.socket, state.socket_options)

    {:ok, context.state}
  end
end
