defmodule TrackearAuthWeb.GithubAuthController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Email
  alias TrackearAuth.Mailer
  alias TrackearAuth.Accounts
  alias TrackearAuth.Accounts.User

  @doc """
  `index/2` handles the callback from Github Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    err_msg = "Hubo problemas al ingresar con tu cuenta de Github. Por favor intentalo de nuevo."
    session_path = "#{System.get_env("TRACKEAR_URL")}/sessions"

    password_length = 32

    password =
      :crypto.strong_rand_bytes(password_length)
      |> Base.encode64()
      |> binary_part(0, password_length)

    with {:ok, profile} <- ElixirAuthGithub.github_auth(code),
         %{email: email, name: name} <- profile,
         user_params = %{email: email, first_name: name, password: password} do
      case Accounts.get_or_create_user_and_return_session(user_params) do
        {:new_user, :ok, session} ->
          Email.welcome_email(conn, email)
          |> Mailer.deliver_later()

          conn
          |> redirect(external: "#{session_path}/#{session.token}")

        {:ok, session} ->
          conn
          |> redirect(external: "#{session_path}/#{session.token}")

        _ ->
          conn
          |> put_flash(:info, err_msg)
          |> redirect(to: Routes.page_path(conn, :index))
      end
    else
      :error ->
        conn
        |> put_flash(:info, err_msg)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
