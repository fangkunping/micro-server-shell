defmodule MicroServerShell do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    MicroServerShell.RpcWorker.init_self()
    MicroServerShell.WebSocketWorker.init_self()
    MicroServerShell.WebSocketUtility.init_self()

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(MicroServerShell.Endpoint, []),
      worker(MicroServerShell.RpcWorker, []),
      worker(MicroServerShell.WebSocketWorker, []),
      worker(MicroServerShell.ConsoleTokenWorker, [])
      # Start your own worker by calling: MicroServerShell.Worker.start_link(arg1, arg2, arg3)
      # worker(MicroServerShell.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MicroServerShell.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MicroServerShell.Endpoint.config_change(changed, removed)
    :ok
  end
end
