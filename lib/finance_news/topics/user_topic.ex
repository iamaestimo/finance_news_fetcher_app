defmodule FinanceNews.Topics.UserTopic do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_topics" do
    field :topic, :string
    belongs_to :user, FinanceNews.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_topic, attrs) do
    user_topic
    |> cast(attrs, [:topic, :user_id])
    |> validate_required([:topic, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
