#!/bin/bash

# Exit if one of the following
# commands fail
set -e

mix deps.get

npm audit fix --prefix ./assets
npm install --prefix ./assets

npm run deploy --prefix ./assets
mix phx.digest priv/static

mix ecto.create
mix ecto.migrate

mix phx.server