defmodule Prototype.Repo do
  use Ecto.Repo,
    otp_app: :prototype,
    adapter: Ecto.Adapters.Postgres
end
