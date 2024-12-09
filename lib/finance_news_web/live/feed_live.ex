defmodule FinanceNewsWeb.FeedLive do
  use FinanceNewsWeb, :live_view
  alias FinanceNews.News.NewsCache

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(FinanceNews.PubSub, "news_updates")
    end

    user = socket.assigns.current_user
    user_topics = FinanceNews.Topics.list_user_topics(user)
    news = NewsCache.get_news_for_topics(Enum.map(user_topics, & &1.topic))

    {:ok, assign(socket,
      news: news,
      loading: false,
      page_title: "Your News Feed"
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold">Your Financial News Feed</h1>
        <div class="text-sm text-gray-500">
          Updates every 15 minutes
        </div>
      </div>

      <%= if @loading do %>
        <div class="animate-pulse space-y-4">
          <%= for _ <- 1..3 do %>
            <div class="bg-gray-100 p-6 rounded-lg">
              <div class="h-4 bg-gray-200 rounded w-3/4"></div>
              <div class="space-y-3 mt-4">
                <div class="h-3 bg-gray-200 rounded"></div>
                <div class="h-3 bg-gray-200 rounded w-5/6"></div>
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class="space-y-6">
          <%= for article <- @news do %>
            <div class="bg-white shadow rounded-lg p-6 hover:shadow-md transition-shadow">
              <div class="flex justify-between items-start">
                <h2 class="text-xl font-semibold mb-2">
                  <a href={article["url"]} target="_blank" class="hover:text-blue-600">
                    <%= article["title"] %>
                  </a>
                </h2>
                <span class="text-sm text-gray-500">
                  <%= format_time(article["time_published"]) %>
                </span>
              </div>

              <p class="text-gray-600 mb-4"><%= article["summary"] %></p>

              <div class="flex flex-wrap gap-2">
                <%= for topic <- (article["topics"] || []) do %>
                  <span class="px-2 py-1 bg-blue-100 text-blue-800 text-sm rounded-full">
                    <%= topic["topic"] %>
                    <span class="text-xs text-blue-600 ml-1">
                      <%= Float.round(String.to_float(topic["relevance_score"]) * 100) %>%
                    </span>
                  </span>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_info({:news_updated, _news_data}, socket) do
    user = socket.assigns.current_user
    user_topics = FinanceNews.Topics.list_user_topics(user)
    news = NewsCache.get_news_for_topics(Enum.map(user_topics, & &1.topic))

    {:noreply, assign(socket, news: news)}
  end

  defp format_time(time_string) do
    case DateTime.from_iso8601(time_string) do
      {:ok, datetime, _} ->
        Calendar.strftime(datetime, "%B %d, %Y %I:%M %p")
      _ ->
        time_string
    end
  end
end
