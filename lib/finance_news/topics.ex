defmodule FinanceNews.Topics do
  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias FinanceNews.Repo

  alias FinanceNews.Topics.UserTopic

  @doc """
  Returns the list of topics for a user.

  ## Examples

      iex> list_user_topics(user)
      [%UserTopic{}, ...]

  """
  def list_user_topics(user) do
    UserTopic
    |> where([t], t.user_id == type(^user.id, :binary_id))
    |> Repo.all()
  end

  @doc """
  Returns a list of unique topics that are currently selected by users.

  ## Examples

      iex> list_unique_active_topics()
      ["tech", "finance", "crypto"]

  """
  def list_unique_active_topics do
    UserTopic
    |> select([t], t.topic)
    |> distinct(true)
    |> Repo.all()
  end

  @doc """
  Creates a user_topic.

  ## Examples

      iex> create_user_topic(%{field: value})
      {:ok, %UserTopic{}}

      iex> create_user_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_topic(attrs \\ %{}) do
    %UserTopic{}
    |> UserTopic.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates user topics.

  This function handles updating a user's topics by replacing all existing topics
  with the new list of topics provided.

  ## Examples

      iex> update_user_topics(user, ["tech", "finance"])
      {:ok, [%UserTopic{}, ...]}

  """
  def update_user_topics(user, topics) when is_list(topics) do
    # Start a transaction
    Repo.transaction(fn ->
      # Delete existing topics
      UserTopic
      |> where([t], t.user_id == type(^user.id, :binary_id))
      |> Repo.delete_all()

      # Insert new topics
      topics
      |> Enum.map(fn topic ->
        {:ok, user_topic} = create_user_topic(%{user_id: user.id, topic: topic})
        user_topic
      end)
    end)
  end

  @doc """
  Deletes a user_topic.

  ## Examples

      iex> delete_user_topic(user_topic)
      {:ok, %UserTopic{}}

      iex> delete_user_topic(user_topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_topic(%UserTopic{} = user_topic) do
    Repo.delete(user_topic)
  end
end
