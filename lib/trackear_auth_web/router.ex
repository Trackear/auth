defmodule TrackearAuthWeb.Router do
  use TrackearAuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TrackearAuthWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/login", PageController, :create
    get "/auth/google/callback", GoogleAuthController, :index
    get "/auth/github/callback", GithubAuthController, :index

    if Mix.env() in [:dev, :test] do
      resources "/users", UserController
      resources "/sessions", SessionController
    else
      resources "/users", UserController, only: [:new, :create]
    end
  end

  scope "/api", TrackearAuthWeb do
    pipe_through :api

    post "/paddle/webhook", PaddleController, :webhook
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    forward "/sent_emails", Bamboo.SentEmailViewerPlug

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TrackearAuthWeb.Telemetry
    end
  end
end
