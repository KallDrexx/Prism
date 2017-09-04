defmodule Prism.Handler do
  @moduledoc """
  A Prism Handler represents a single self contained unit of code that performs
  transformation and logic processing on inputs and outputs.  Handlers are meant
  to be composed together to form a pipeline where each handler takes a bit of input
  or output and transforms it before passing it along to the next handler in the pipeline.

  When handlers are created they are registered with a parent handler PID and child handler PID.
  Inputs flow in from the parent, processed by the local handler, then (assuming the
  business logic warrants it) continues on to the child handler.  On the other hand outputs flow
  in the reverse order by coming in from the child handler, being processed locally by current handler,
  then passed up to the parent.

  handlers are required to have a parent, but are not required to have a child.  A parent may be
  another handler or may be an I/O handler.  Children are typically handlers, and end to end
  streaming of data from one I/O endpoint to another is usually done by an inbound pipeline
  sending data to an outbound pipeline.
  """

  use GenServer

  @type adopter_module :: module
  @type adopter_args :: any
  @type adopter_state :: any
  @type input :: any
  @type output :: any

  @callback init(adopter_args) :: {:ok, adopter_state}
  @callback input_received(HandlerContext.t, input) :: {:ok, adopter_state}
  @callback output_received(HandlerContext.t, output) :: {:ok, adopter_state}
  @callback handle_message(HandlerContext.t, any) :: {:ok, adopter_state}

  defmodule State do
    @moduledoc false

    defstruct adopter_module: nil,
              adopter_state: nil,
              parent_pid: nil,
              child_pid: nil
  end

  def start_link(parent_pid, adopter_module, adopter_args) do
    GenServer.start_link(__MODULE__, [parent_pid, adopter_module, adopter_args])
  end

  def register_child(parent_pid, handler_pid) when is_pid(handler_pid) do
    GenServer.cast(parent_pid, {:register_child, handler_pid})
  end

  def relay_input(child_pid, input) do
    GenServer.cast(child_pid, {:input_received, input})
  end

  def relay_output(parent_pid, output) do
    GenServer.cast(parent_pid, {:output_received, output})
  end

  @doc false
  def init([parent_pid, adopter_module, adopter_args]) do
    {:ok, adopter_state} = adopter_module.init(adopter_args)

    state = %State{
      adopter_module: adopter_module,
      adopter_state: adopter_state,
      parent_pid: parent_pid
    }

    {:ok, state}
  end

  @doc false
  def handle_cast({:register_child, pid}, state) do
    state = %{state | child_pid: pid}
    {:noreply, state}
  end

  @doc false
  def handle_cast({:input_received, input}, state) do
    context = %Prism.HandlerContext{
      parent_pid: state.parent_pid,
      child_pid: state.child_pid,
      state: state.adopter_state
    }

    {:ok, adopter_state} = state.adopter_module.input_received(context, input)
    state = %{state | adopter_state: adopter_state}
    {:noreply, state}
  end

  @doc false
  def handle_cast({:output_received, output}, state) do
    context = %Prism.HandlerContext{
      parent_pid: state.parent_pid,
      child_pid: state.child_pid,
      state: state.adopter_state
    }

    {:ok, adopter_state} = state.adopter_module.output_received(context,output)
    state = %{state | adopter_state: adopter_state}
    {:noreply, state}
  end

  @doc false
  def handle_info(message, state) do
    context = %Prism.HandlerContext{
      parent_pid: state.parent_pid,
      child_pid: state.child_pid,
      state: state.adopter_state
    }

    test = self()

    {:ok, adopter_state} = state.adopter_module.handle_message(context, message)
    state = %{state | adopter_state: adopter_state}
    {:noreply, state}
  end

end
