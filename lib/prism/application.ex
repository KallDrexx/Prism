defmodule Prism.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Prism.Trigger, [
        Prism.Triggers.RanchTcpAcceptor,
        [:test, 1111, [active: :once, packet: :line]],
          [
            {Prism.Handlers.ReverseTextHandler, []},
            {Prism.Handlers.EchoHandler, []}
          ]
        ]}

      # Starts a worker by calling: Prism.Worker.start_link(arg)
      # {Prism.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Prism.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
