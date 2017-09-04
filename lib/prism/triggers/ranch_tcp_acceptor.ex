defmodule Prism.Triggers.RanchTcpAcceptor do
  @moduledoc """
  Prism trigger that creates a pipeline when a new TCP
"""
  
  @behaviour Prism.Trigger

  defmodule State do
    @moduledoc false

    defstruct port: nil,
              listener_name: nil,
              listener_pid: nil,
              socket_options: [],
              handlers: []
  end

  def init(handlers, [name, port, socket_options]) do
    {:ok, _} = Application.ensure_all_started(:ranch)



    options = [port: port]
    {:ok, pid} = :ranch.start_listener(
      name,
      :ranch_tcp,
      options,
      Prism.Triggers.RanchTcpAcceptor.Protocol,
      [socket_options, handlers]
    )

    state = %State{
      listener_name: name,
      port: port,
      socket_options: socket_options,
      listener_pid: pid
    }

    {:ok, state}
  end

  defmodule Protocol do
    defmodule State do
      @moduledoc false

      defstruct socket: nil,
                transport: nil,
                handlers: nil,
                socket_options: nil
    end

    def start_link(ref, socket, transport, [socket_options, handlers]) do
      pid = spawn_link(__MODULE__, :init, [ref, socket, transport, socket_options, handlers])
      {:ok, pid}
    end

    def init(ref, socket, transport, socket_options, handlers) do
      :ok = :ranch.accept_ack(ref)
      :ok = transport.setopts(socket, socket_options)

      # Add the tcp socket handler to the top of the handler list
      handlers = [{Prism.Handlers.TcpSocketHandler, [transport, socket, socket_options]} | handlers]

      {:ok, pipeline_pid} = Prism.Pipeline.start_link(handlers)
      {:ok, first_pid} = Prism.Pipeline.get_first_pid(pipeline_pid)
      case first_pid do
        pid when is_pid(pid) -> transport.controlling_process(socket, pid)
        pid when is_pid(pid) -> transport.controlling_process(socket, pid)
      end

      loop()

    end

    defp loop() do
      :timer.sleep(1000)
      loop()
    end
  end

end
