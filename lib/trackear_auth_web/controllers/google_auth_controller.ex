defmodule TrackearAuthWeb.GoogleAuthController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Email
  alias TrackearAuth.Mailer
  alias TrackearAuth.Accounts
  alias TrackearAuth.Accounts.User

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    err_msg = "Hubo problemas al ingresar con tu cuenta de Google. Por favor intentalo de nuevo."
    session_path = "#{System.get_env("TRACKEAR_URL")}/sessions"

    with {:ok, token} <- ElixirAuthGoogle.get_token(code, conn),
         %{access_token: access_token} <- token,
         {:ok, profile} <- ElixirAuthGoogle.get_user_profile(access_token) do
      user_params = %{
        email: profile.email,
        first_name: profile.given_name,
        last_name: profile.family_name
      }

      case Accounts.get_or_create_user_and_return_session(user_params) do
        {:new_user, :ok, session} ->
          Email.welcome_email(conn, profile.email)
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
      _ ->
        conn
        |> put_flash(:info, err_msg)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
