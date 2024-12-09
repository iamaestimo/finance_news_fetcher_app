defmodule FinanceNews.Repo.Migrations.CreateUserTopics do
  use Ecto.Migration

  def change do
    # drop_if_exists table(:user_topics)

    # create table(:user_topics, primary_key: false) do
    #   add :id, :binary_id, primary_key: true
    #   add :topic, :string, null: false
    #   add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false

    #   timestamps()
    # end

    # create index(:user_topics, [:user_id])
  end
end
