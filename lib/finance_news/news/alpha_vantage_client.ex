defmodule FinanceNews.News.AlphaVantageClient do
  @base_url "https://www.alphavantage.co/query"
  @timeout :timer.seconds(15)
  @pool_timeout :timer.seconds(20)
  @max_retries 3
  @retry_delay 1000

  def fetch_news(topics, retry_count \\ 0) when is_list(topics) do
    Appsignal.instrument("AlphaVantage.fetch_news", fn ->
      if Enum.empty?(topics) do
        {:ok, %{"feed" => []}}
      else
        topics_string = topics |> Enum.join(",")

        query_params = URI.encode_query(%{
          "function" => "NEWS_SENTIMENT",
          "topics" => topics_string,
          "apikey" => api_key(),
          "sort" => "LATEST",
          "limit" => "50"
        })

        url = "#{@base_url}?#{query_params}"

        case make_request(url, retry_count) do
          {:ok, response} -> {:ok, response}
          {:error, reason} -> {:error, reason}
        end
      end
    end)
  end

  defp make_request(url, retry_count) do
    case Finch.build(:get, url)
         |> Finch.request(FinanceNewsFinch,
           receive_timeout: @timeout,
           pool_timeout: @pool_timeout) do
      {:ok, %Finch.Response{body: body, status: 200}} ->
        case Jason.decode(body) do
          {:ok, decoded} -> {:ok, decoded}
          {:error, _} -> {:error, "Invalid JSON response"}
        end

      {:ok, %Finch.Response{status: 429}} ->
        handle_retry("Rate limited", url, retry_count)

      {:ok, %Finch.Response{status: status}} ->
        handle_retry("API returned status #{status}", url, retry_count)

      {:error, %Mint.TransportError{reason: :timeout}} ->
        handle_retry("Request timed out", url, retry_count)

      {:error, reason} ->
        handle_retry("Request failed: #{inspect(reason)}", url, retry_count)
    end
  end

  defp handle_retry(reason, url, retry_count) do
    if retry_count < @max_retries do
      Process.sleep(@retry_delay)
      make_request(url, retry_count + 1)
    else
      {:error, reason}
    end
  end

  defp api_key do
    case Application.fetch_env!(:finance_news, :alphavantage_api_key) do
      key when is_binary(key) and byte_size(key) > 0 -> key
      _ -> raise "Invalid or missing AlphaVantage API key"
    end
  end
end
