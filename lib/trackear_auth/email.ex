defmodule TrackearAuth.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: TrackearAuthWeb.EmailView

  def welcome_email(conn, email) do
    new_email(
      to: email,
      from: System.get_env("EMAIL_FROM"),
      subject: "Bienvenido a Trackear.app"
    )
    |> render(:welcome, conn: conn)
  end
end
