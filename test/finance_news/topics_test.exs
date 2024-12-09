defmodule FinanceNews.TopicsTest do
  use FinanceNews.DataCase

  alias FinanceNews.Topics

  describe "user_topics" do
    alias FinanceNews.Topics.UserTopic

    import FinanceNews.TopicsFixtures

    @invalid_attrs %{topic: nil}

    test "list_user_topics/0 returns all user_topics" do
      user_topic = user_topic_fixture()
      assert Topics.list_user_topics() == [user_topic]
    end

    test "get_user_topic!/1 returns the user_topic with given id" do
      user_topic = user_topic_fixture()
      assert Topics.get_user_topic!(user_topic.id) == user_topic
    end

    test "create_user_topic/1 with valid data creates a user_topic" do
      valid_attrs = %{topic: "some topic"}

      assert {:ok, %UserTopic{} = user_topic} = Topics.create_user_topic(valid_attrs)
      assert user_topic.topic == "some topic"
    end

    test "create_user_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Topics.create_user_topic(@invalid_attrs)
    end

    test "update_user_topic/2 with valid data updates the user_topic" do
      user_topic = user_topic_fixture()
      update_attrs = %{topic: "some updated topic"}

      assert {:ok, %UserTopic{} = user_topic} = Topics.update_user_topic(user_topic, update_attrs)
      assert user_topic.topic == "some updated topic"
    end

    test "update_user_topic/2 with invalid data returns error changeset" do
      user_topic = user_topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Topics.update_user_topic(user_topic, @invalid_attrs)
      assert user_topic == Topics.get_user_topic!(user_topic.id)
    end

    test "delete_user_topic/1 deletes the user_topic" do
      user_topic = user_topic_fixture()
      assert {:ok, %UserTopic{}} = Topics.delete_user_topic(user_topic)
      assert_raise Ecto.NoResultsError, fn -> Topics.get_user_topic!(user_topic.id) end
    end

    test "change_user_topic/1 returns a user_topic changeset" do
      user_topic = user_topic_fixture()
      assert %Ecto.Changeset{} = Topics.change_user_topic(user_topic)
    end
  end
end
