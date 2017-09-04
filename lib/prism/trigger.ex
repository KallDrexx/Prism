defmodule Prism.Trigger do
  @moduledoc """

  A prism trigger waits for a condition to be met and will then spawn a
  pipeline with the handlers specified on creation.  It is up to the trigger
  adopter to determine what the actual conditions are that will spawn a pipeline.

  For example, one trigger might be created to spawn a specific pipeline each time
  an incoming tcp connection is made on a specific port.  Another trigger might
  only create a pipeline on a manual invocation.
  """

  use GenServer

  @type arguments :: any
  @type adopter_module :: module
  @type adopter_state :: any
  @type handler :: {module, arguments}

  @callback init([handler], arguments) :: {:ok, adopter_state}

  defmodule State do
    @moduledoc false

    defstruct adopter_module: nil,
              adopter_state: nil,
              handlers: []
  end

  def start_link([adopter_module, trigger_arguments, handlers]) do
    start_link(adopter_module, trigger_arguments, handlers)
  end

  def start_link(adopter_module, trigger_arguments, handlers) do
    GenServer.start_link(__MODULE__, [adopter_module, trigger_arguments, handlers])
  end

  def activate(trigger_pid) do
    GenServer.cast(trigger_pid, :activate)
  end

  def deactivate(trigger_pid) do
    GenServer.cast(trigger_pid, :deactivate)
  end

  @doc false
  def init([adopter_module, trigger_arguments, handlers]) do
    {:ok, adopter_state} = adopter_module.init(handlers, trigger_arguments)

    state = %State{
      adopter_module: adopter_module,
      adopter_state: adopter_state,
      handlers: handlers
    }

    {:ok, state}
  end

end
