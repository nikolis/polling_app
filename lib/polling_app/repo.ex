defmodule PollingApp.Repo do
  use Ecto.Repo,
    otp_app: :polling_app,
    adapter: Ecto.Adapters.SQLite3
end
