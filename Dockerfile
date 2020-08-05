FROM bitwalker/alpine-elixir:1.10.3 as build

# install build dependencies
RUN apk add --update git build-base nodejs nodejs-npm yarn python

# prepare build dir
RUN mkdir /app
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# build assets
COPY assets assets
RUN cd assets && npm install && npm run deploy

# build project
COPY priv priv
COPY lib lib
RUN mix phx.digest
RUN mix compile

# build release
RUN MIX_ENV=prod mix release

# prepare release image
FROM bitwalker/alpine-erlang:latest as app

RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

ENV PORT=4000

COPY --from=build /app/_build/prod/rel/test_app ./
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app

ENTRYPOINT ["./bin/test_app", "start"]