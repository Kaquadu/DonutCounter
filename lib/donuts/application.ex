defmodule Donuts.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Donuts.Repo, []),
      # Start the endpoint when the application starts
      supervisor(DonutsWeb.Endpoint, []),
      # Start your own worker by calling: Donuts.Worker.start_link(arg1, arg2, arg3)
      # worker(Donuts.Worker, [arg1, arg2, arg3]),
      #{Donuts.Background.UserManager, []},
      {Donuts.Background.ExpirationChecker, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Donuts.Supervisor]
    start_result = Supervisor.start_link(children, opts)

    # Run migrations on start
    Ecto.Migrator.run(Donuts.Repo, "priv/repo/migrations", :up, all: true)

    start_result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DonutsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
