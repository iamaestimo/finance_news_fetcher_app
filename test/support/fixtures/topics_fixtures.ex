defmodule FinanceNews.TopicsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FinanceNews.Topics` context.
  """

  @doc """
  Generate a user_topic.
  """
  def user_topic_fixture(attrs \\ %{}) do
    {:ok, user_topic} =
      attrs
      |> Enum.into(%{
        topic: "some topic"
      })
      |> FinanceNews.Topics.create_user_topic()

    user_topic
  end
end
