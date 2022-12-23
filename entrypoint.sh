#!/bin/sh
# Wait until Postgres is ready.
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0

MIX_ENV=prod mix ecto.migrate
PORT=4001 MIX_ENV=prod mix phx.server