defmodule FinanceNewsWeb.FeedLive do
  use FinanceNewsWeb, :live_view
  alias FinanceNews.News.NewsCache

  # In lib/finance_news_web/live/feed_live.ex
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(FinanceNews.PubSub, "news_updates")
  end

  # Add debug logging
  require Logger
  user = socket.assigns.current_user
  Logger.debug("User: #{inspect(user)}")

  user_topics = FinanceNews.Topics.list_user_topics(user)
  Logger.debug("User topics: #{inspect(user_topics)}")

  # Get topic list, ensuring we have a list even if user_topics is nil
  topic_list = (user_topics || []) |> Enum.map(& &1.topic)
  Logger.debug("Topic list: #{inspect(topic_list)}")

  news = if Enum.empty?(topic_list) do
    []
  else
    NewsCache.get_news_for_topics(topic_list)
  end

  {:ok, assign(socket,
    news: news,
    loading: false,
    page_title: "News Feed - Finance Tracker App",
    has_topics: not Enum.empty?(topic_list)
  )}
end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold">Your Personalized Financial News Feed</h1>
        <div class="text-sm text-gray-500">
          Updates every 5 minutes
        </div>
      </div>

      <%= if not @has_topics do %>
        <div class="text-center py-8">
          <p class="text-xl text-gray-600 mb-4">No topics selected yet</p>
          <.link navigate={~p"/topics"} class="inline-block px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
            Select Topics
          </.link>
        </div>
      <% else %>
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
      <% end %>
    </div>
    """
  end

  def handle_info({:news_updated, _news_data}, socket) do
    user = socket.assigns.current_user
    user_topics = FinanceNews.Topics.list_user_topics(user)

    # Ensure we have a valid list of topics
    topic_list = case user_topics do
      nil -> []
      topics -> Enum.map(topics, & &1.topic)
    end

    news = if Enum.empty?(topic_list) do
      []
    else
      NewsCache.get_news_for_topics(topic_list)
    end

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
