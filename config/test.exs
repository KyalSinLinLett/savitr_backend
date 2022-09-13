import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :savitr_backend, SavitrBackend.Repo,
  username: "postgres",
  password: "<some-secure-password>",
  hostname: "localhost",
  database: "savitr_backend_dev_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :savitr_backend, SavitrBackendWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "9NndZyLZ+fZHWW6YPEJJwhA8ACx4SHotwD7LLj3SSEISDp0/CWLpQaSSEfbi2rmP",
  server: false

# In test we don't send emails.
config :savitr_backend, SavitrBackend.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
