defmodule TrackearAuthWeb.GoogleAuthController do
  use TrackearAuthWeb, :controller

  alias TrackearAuth.Accounts
  alias TrackearAuth.Accounts.User

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)

    case token do
      %{access_token: access_token} ->
        {:ok, profile} = ElixirAuthGoogle.get_user_profile(access_token)

        password_length = 32
        password = :crypto.strong_rand_bytes(password_length)
        |> Base.encode64
        |> binary_part(0, password_length)

        user_params = %{
          email: profile.email,
          first_name: profile.given_name,
          last_name: profile.family_name,
          password: password,
        }

        case Accounts.get_or_create_user_and_return_session(user_params) do
          {:ok, session} ->
            conn
            |> redirect(external: "https://www.trackear.app/sessions/#{session.token}")

          {:error, changeset} ->
            conn
            |> put_flash(:info, "Hubo problemas al ingresar con tu cuenta de Google.")
            |> redirect(to: Routes.page_path(conn, :index))
        end

      _ ->
        conn
        |> put_flash(:info, "Hubo problemas al ingresar con tu cuenta de Google.")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
