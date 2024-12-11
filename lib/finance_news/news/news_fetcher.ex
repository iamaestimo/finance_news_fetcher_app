defmodule FinanceNews.News.NewsFetcher do
  use GenServer
  require Logger
  alias FinanceNews.News.AlphaVantageClient
  alias FinanceNews.News.NewsCache

  @refresh_interval :timer.minutes(5)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_update()
    {:ok, state}
  end

  def handle_info(:fetch_news, state) do
    fetch_all_news()
    schedule_update()
    {:noreply, state}
  end

  defp schedule_update do
    Process.send_after(self(), :fetch_news, @refresh_interval)
  end

  defp fetch_all_news do
    # Get unique topics from all users
    topics = FinanceNews.Topics.list_unique_active_topics()

    case AlphaVantageClient.fetch_news(topics) do
      {:ok, news_data} ->
        NewsCache.update_cache(news_data)
      {:error, reason} ->
        Logger.error("Failed to fetch news: #{inspect(reason)}")
    end
  end
end
