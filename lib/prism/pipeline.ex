defmodule Prism.Pipeline do
  @moduledoc """

  A pipeline is a process that manages a collection of handlers.
  """
  
  use GenServer

  @type arguments :: any
  @type handler_spec :: {module, arguments}

  defmodule State do
    @moduledoc false

    defstruct handler_pids: []
  end

  def start_link(handlers) do
    GenServer.start_link(__MODULE__, handlers)
  end

  def get_first_pid(pipeline_pid) do
    GenServer.call(pipeline_pid, :get_first_pid)
  end

  @doc false
  def init(handler_specs) do
    handler_pids = start_handlers(handler_specs)
    state = %State{handler_pids: handler_pids}
    {:ok, state}
  end

  defp start_handlers(handler_specs) do
    start_handlers(handler_specs, [], nil)
  end

  defp start_handlers([{module, args} | rest], handler_pids, last_handler_pid) do
    {:ok, new_handler} = Prism.Handler.start_link(last_handler_pid, module, args)
    case last_handler_pid do
      last_handler when is_pid(last_handler) -> Prism.Handler.register_child(last_handler, new_handler)
      nil -> :ok
    end

    handler_pids = [new_handler | handler_pids]
    start_handlers(rest, handler_pids, new_handler)
  end

  defp start_handlers([], handler_pids, _) do
    Enum.reverse(handler_pids)
  end

  @doc false
  def handle_call(:get_first_pid, _, state) do
    case state.handler_pids do
      [head | _] -> {:reply, {:ok, head}, state}
      [] -> {:reply, {:ok, nil}, state}
    end
  end
end
