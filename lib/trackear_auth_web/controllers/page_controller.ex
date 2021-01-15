defmodule TrackearAuthWeb.PageController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Email
  alias TrackearAuth.Mailer
  alias TrackearAuth.Accounts
  alias TrackearAuth.Accounts.User
  alias TrackearAuth.Accounts.Session

  def index(conn, _params) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    oauth_github_url = ElixirAuthGithub.login_url()
    changeset = Accounts.change_user(%User{})

    Email.welcome_email()   # Create your email
    |> Mailer.deliver_now() # Send your email

    render(conn, "index.html", [
      oauth_google_url: oauth_google_url,
      oauth_github_url: oauth_github_url,
      changeset: changeset
    ])
  end

  def create(conn, %{"user" => user_params}) do
    oauth_google_url = ElixirAuthGoogle.generate_oauth_url(conn)
    oauth_github_url = ElixirAuthGithub.login_url()
    email = user_params["email"]
    password = user_params["password"]

    case Accounts.create_session_from_credentials(email, password) do
      {:ok, session} ->
        conn
        |> redirect(external: "#{System.get_env("TRACKEAR_URL")}/sessions/#{session.token}")

      {:error, changeset} ->
        render(conn, "index.html", [
          oauth_google_url: oauth_google_url,
          oauth_github_url: oauth_github_url,
          changeset: changeset,
        ])
    end
  end
end
