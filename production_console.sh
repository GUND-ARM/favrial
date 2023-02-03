#!/bin/sh

set -eu

. production.env

: "${SSH_HOST}"
: "${COMPOSE_PROJECT_NAME}"
: "${APP_WEB_PORT}"
: "${SECRET_KEY_BASE}"
: "${TWITTER_CLIENT_ID}"
: "${TWITTER_CLIENT_SECRET}"

DOCKER_HOST="ssh://${SSH_HOST}"

export DOCKER_HOST
export COMPOSE_PROJECT_NAME
export APP_WEB_PORT
export SECRET_KEY_BASE
export TWITTER_CLIENT_ID
export TWITTER_CLIENT_SECRET

docker_compose() {
  docker compose -f docker-compose.yml -f production.yml "$@"
}

docker_compose run --rm web rails console
