defmodule MeApp.Repo do
  use Ecto.Repo,
    otp_app: :me_app,
    adapter: Ecto.Adapters.Postgres
end
