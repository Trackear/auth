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
    case ElixirAuthGithub.github_auth(code) do
      {:ok, profile} ->
        case profile do
          %{email: email, name: name} ->
            password_length = 32
            password = :crypto.strong_rand_bytes(password_length)
            |> Base.encode64
            |> binary_part(0, password_length)

            user_params = %{
              email: email,
              first_name: name,
              password: password,
            }

            case Accounts.get_or_create_user_and_return_session(user_params) do
              {:new_user, :ok, session} ->
                Email.welcome_email(conn, email)
                |> Mailer.deliver_later()

                conn
                |> redirect(external: "#{System.get_env("TRACKEAR_URL")}/sessions/#{session.token}")

              {:ok, session} ->
                conn
                |> redirect(external: "#{System.get_env("TRACKEAR_URL")}/sessions/#{session.token}")

              _ ->
                conn
                |> put_flash(:info, "Hubo problemas al ingresar con tu cuenta de Github. Por favor intentalo de nuevo.")
                |> redirect(to: Routes.page_path(conn, :index))
            end
          _ ->
            conn
            |> put_flash(:info, "Hubo problemas al ingresar con tu cuenta de Github. Por favor intentalo de nuevo.")
            |> redirect(to: Routes.page_path(conn, :index))
        end
      _ ->
        conn
        |> put_flash(:info, "Hubo problemas al ingresar con tu cuenta de Github. Por favor intentalo de nuevo.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
