defmodule TrackearAuth.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: TrackearAuthWeb.EmailView

  def welcome_email do
    new_email(
      to: "john@example.com",
      from: System.get_env("EMAIL_FROM"),
      subject: "Welcome to the app.",
    )
    |> render(:welcome)
  end
end
