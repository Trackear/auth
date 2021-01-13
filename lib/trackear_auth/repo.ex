defmodule TrackearAuth.Repo do
  use Ecto.Repo,
    otp_app: :trackear_auth,
    adapter: Ecto.Adapters.Postgres
end
