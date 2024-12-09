defmodule FinanceNews.News.NewsCache do
  use GenServer

  @table_name :news_cache

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(@table_name, [:set, :named_table, :public])
    {:ok, nil}
  end

  def get_news_for_topics(topics) when is_list(topics) do
    case :ets.lookup(@table_name, :news) do
      [{:news, all_news}] ->
        filter_news_by_topics(all_news, topics)
      [] ->
        []
    end
  end

  def update_cache(news_data) do
    :ets.insert(@table_name, {:news, news_data})
    Phoenix.PubSub.broadcast(FinanceNews.PubSub, "news_updates", {:news_updated, news_data})
  end

  defp filter_news_by_topics(news, topics) do
    news["feed"]
    |> Enum.filter(fn article ->
      article_topics = article["topics"] || []
      Enum.any?(topics, fn user_topic ->
        Enum.any?(article_topics, fn article_topic ->
          # Extract the topic string from the topic object
          topic_string = article_topic["topic"]
          String.contains?(
            String.downcase(topic_string),
            String.downcase(user_topic)
          )
        end)
      end)
    end)
  end
end
