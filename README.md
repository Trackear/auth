# Trackear Auth

Project to handle accounts and sessions creation for Trackear.app.

## Install

- Install docker
- Install docker-compose
- Make a copy of .env.sample and rename it to .env
- Make sure to complete the environment variables
- Run docker-compose up
- Once completed, the app will be running on http://localhost:4000

## Environment variables

- **TRACKEAR_URL:** Full URL of the main page
- **GOOGLE_CLIENT_ID:** Client ID from Google
- **GOOGLE_CLIENT_SECRET:** Client secret from Google
- **GITHUB_CLIENT_ID:** Client ID from Github
- **GITHUB_CLIENT_SECRET:** Client secret from Github
- **EMAIL_FROM: Email** address from where emails will be sent
- **PADDLE_SECRET:** Secret used in Paddle webhook URL.

## Paddle webhook

The Paddle webhook, is the endpoint that will be called from Paddle when
a new subscription is created. It can be configured from https://vendors.paddle.com/alerts-webhooks.

You can use the `PADDLE_SECRET` adding it as a query parameter. For example:

`URL for receiving webhook alerts: https://your-page.com/paddle/webhook?secret=YOUR_SECRET`

This way, if the secret doesn't match, the endpoint won't do anything and we can
be fairly confident that the endpoint, is being called by Paddle.

## Linter

`mix credo`

or

`docker-compose run --rm app mix credo`

## Formatter

`mix format mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"`

or

`docker-compose run --rm app mix format mix.exs "lib/**/*.{ex,exs}" "test/**/*.{ex,exs}"`

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
