defmodule FinanceNews.Repo do
  use Ecto.Repo,
    otp_app: :finance_news,
    adapter: Ecto.Adapters.Postgres
end
