defmodule SavitrBackend.Repo do
  use Ecto.Repo,
    otp_app: :savitr_backend,
    adapter: Ecto.Adapters.Postgres
end
