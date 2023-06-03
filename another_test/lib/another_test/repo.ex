defmodule AnotherTest.Repo do
  use Ecto.Repo,
    otp_app: :another_test,
    adapter: Ecto.Adapters.Postgres
end
