defmodule TrackearAuthWeb.PageController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Accounts
  alias TrackearAuth.Accounts.User

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

    case Accounts.get_user_from_credentials(email, password) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))
      :error ->
        render(conn, "index.html", [
          oauth_google_url: oauth_google_url,
          changeset: Accounts.change_user(%User{}, user_params),
        ])
    end
  end
end
