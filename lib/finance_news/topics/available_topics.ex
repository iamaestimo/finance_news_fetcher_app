defmodule FinanceNews.Topics.AvailableTopics do
  @moduledoc """
  Defines the available topics that users can select from.
  """

  @doc """
  Returns a list of tuples containing topic IDs and their labels.
  """
  def all do
    [
      {"stocks", "Stocks & Equities"},
      {"crypto", "Cryptocurrency"},
      {"forex", "Foreign Exchange"},
      {"commodities", "Commodities"},
      {"economy", "Economy & Policy"},
      {"real_estate", "Real Estate"},
      {"startups", "Startups & VC"},
      {"tech", "Technology"},
      {"banking", "Banking & Finance"}
    ]
  end
end
