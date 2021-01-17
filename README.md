# Trackear Auth

Project to handle accounts and sessions creation for Trackear.app.

## Install

- Install docker
- Install docker-compose
- Make a copy of .env.sample and rename it to .env
- Make sure to complete the environment variables
- Run docker-compose up
- Once completed, the app will be running on http://localhost:4000

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
