#!/bin/sh

set -eu

. production.env

export DOCKER_HOST
export COMPOSE_PROJECT_NAME
export APP_WEB_PORT
export SECRET_KEY_BASE
export TWITTER_CLIENT_ID
export TWITTER_CLIENT_SECRET

docker_compose() {
  docker compose -f docker-compose.yml -f production.yml "$@"
}

docker_compose build
#docker_compose down
# ssh経由でcompose downが動かない問題のワークアラウンド
ssh -t favrial -- docker compose -p "${COMPOSE_PROJECT_NAME}" down
#docker_compose run --rm web rails db:create  # 初回のみ
docker_compose run --rm web rails db:migrate
docker_compose up -d --remove-orphans
