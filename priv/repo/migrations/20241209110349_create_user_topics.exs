defmodule FinanceNews.Repo.Migrations.CreateUserTopics do
  use Ecto.Migration

  def change do
    create table(:user_topics, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :topic, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_topics, [:user_id])
    # Ensure a user can't select the same topic twice
    create unique_index(:user_topics, [:user_id, :topic])
  end
end
