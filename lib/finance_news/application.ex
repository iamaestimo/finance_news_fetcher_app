defmodule FinanceNews.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FinanceNewsWeb.Telemetry,
      FinanceNews.Repo,
      {DNSCluster, query: Application.get_env(:finance_news, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: FinanceNews.PubSub},
      # Configure Finch with proper pool configuration
      {Finch, name: FinanceNewsFinch,
        pools: %{
          "https://www.alphavantage.co" => [
            size: 10,
            count: 2,
            protocol: :http1
          ]
        }
      },
      FinanceNews.News.NewsCache,
      FinanceNews.News.NewsFetcher,
      FinanceNewsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FinanceNews.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FinanceNewsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
