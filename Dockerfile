# Use an official Elixir runtime as a parent image.
FROM elixir:latest

RUN apt-get update && \
    apt-get install -y postgresql-client

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app
WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force

# Initial setup
RUN mix deps.get --only prod
RUN MIX_ENV=prod mix compile

# Compile assets
RUN MIX_ENV=prod mix assets.deploy

# # Custom tasks (like DB migrations)
# RUN MIX_ENV=prod mix ecto.migrate

RUN chmod +x /app/entrypoint.sh

# CMD ["/app/entrypoint.sh"]