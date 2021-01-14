#!/bin/bash

npm audit fix --prefix ./assets || exit 1
npm install --prefix ./assets || exit 1

npm run deploy --prefix ./assets || exit 1
mix phx.digest priv/static || exit 1

mix ecto.create || exit 1
mix ecto.migrate || exit 1

mix phx.server