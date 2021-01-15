defmodule TrackearAuthWeb.PageController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Accounts
  alias TrackearAuth.Accounts.User
  alias TrackearAuth.Accounts.Session

  def index(conn, _params) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    changeset = Accounts.change_user(%User{})
    render(conn, "index.html", [
      oauth_google_url: oauth_google_url,
      changeset: changeset
    ])
  end

  def create(conn, %{"user" => user_params}) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    email = user_params["email"]
    password = user_params["password"]

    case Accounts.create_session_from_credentials(email, password) do
      {:ok, session} ->
        conn
        |> redirect(external: "https://www.trackear.app/sessions/#{session.token}")

      {:error, changeset} ->
        render(conn, "index.html", [
          oauth_google_url: oauth_google_url,
          changeset: changeset,
        ])
    end
  end
end
