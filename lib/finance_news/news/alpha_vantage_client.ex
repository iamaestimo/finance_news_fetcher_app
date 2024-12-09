defmodule FinanceNews.News.AlphaVantageClient do
  @base_url "https://www.alphavantage.co/query"
  @timeout :timer.seconds(15)  # 15 second timeout
  @pool_timeout :timer.seconds(20)  # 20 second pool timeout
  @max_retries 3
  @retry_delay 1000 # 1 second

  def fetch_news(topics, retry_count \\ 0) when is_list(topics) do
    topics_string = topics |> Enum.join(",")

    query_params = URI.encode_query(%{
      "function" => "NEWS_SENTIMENT",
      "topics" => topics_string,
      "apikey" => api_key(),
      "sort" => "LATEST",
      "limit" => "50"
    })

    url = "#{@base_url}?#{query_params}"

    # Add timeout options to the request
    case Finch.build(:get, url)
         |> Finch.request(FinanceNewsFinch,
           receive_timeout: @timeout,
           pool_timeout: @pool_timeout) do
      {:ok, %Finch.Response{body: body, status: 200}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %Finch.Response{status: status}} ->
        {:error, "API returned status #{status}"}

      {:error, %Mint.TransportError{reason: :timeout}} ->
        {:error, "Request timed out after #{@timeout}ms"}

      {:error, reason} ->
        {:error, "Failed to fetch news: #{inspect(reason)}"}
    end

    case make_request(url) do
      {:ok, response} ->
        {:ok, response}

      {:error, _reason} when retry_count < @max_retries ->
        Process.sleep(@retry_delay)
        fetch_news(topics, retry_count + 1)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp make_request(url) do
    Finch.build(:get, url)
    |> Finch.request(FinanceNewsFinch,
      receive_timeout: @timeout,
      pool_timeout: @pool_timeout)
    |> handle_response()
  end

  defp handle_response({:ok, %Finch.Response{body: body, status: 200}}) do
    {:ok, Jason.decode!(body)}
  end

  defp handle_response({:ok, %Finch.Response{status: status}}) do
    {:error, "API returned status #{status}"}
  end

  defp handle_response({:error, %Mint.TransportError{reason: :timeout}}) do
    {:error, "Request timed out"}
  end

  defp handle_response({:error, reason}) do
    {:error, "Failed to fetch news: #{inspect(reason)}"}
  end

  defp api_key, do: Application.fetch_env!(:finance_news, :alphavantage_api_key)
end
