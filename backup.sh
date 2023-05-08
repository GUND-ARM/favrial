#!/bin/sh
#
# 定期バックアップを取るためのスクリプト
#   - 日時でGitHub Actionsから実行されている
#

set -eu

: "${SSH_HOST}"
: "${COMPOSE_PROJECT_NAME}"

docker_compose() {
  DOCKER_HOST="ssh://${SSH_HOST}"
  export DOCKER_HOST
  docker compose -p "${COMPOSE_PROJECT_NAME}" -f docker-compose.yml -f production.yml "$@"
}

date=$(date '+%Y%m%d%H%M%S')
filename="favrial_production_${date}.dump"
docker_compose exec db pg_dump -Fc -U postgres -d app_production > "${filename}"
