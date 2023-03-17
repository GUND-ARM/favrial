#!/bin/sh
#
# 使い方:
#  ./deploy.sh [-i <backup_file>] [-c]
#    -i <backup_file>  DBをインポートする
#    -c                DBを作成する
#

set -eu

: "${SSH_HOST}"
: "${COMPOSE_PROJECT_NAME}"
: "${APP_WEB_PORT}"
: "${SECRET_KEY_BASE}"
: "${TWITTER_CLIENT_ID}"
: "${TWITTER_CLIENT_SECRET}"

docker_compose() {
  DOCKER_HOST="ssh://${SSH_HOST}"
  export DOCKER_HOST
  docker compose -f docker-compose.yml -f production.yml "$@"
}

set +u
import=0
create=0
while getopts "i:c" opt; do
  case ${opt} in
    i)
      import=1
      backup_file="${OPTARG}"
      ;;
    c)
      create=1
      ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      echo "Usage: $0 [-i <backup_file>] [-c]" 1>&2
      echo "  -i <backup_file>  DBをインポートする" 1>&2
      echo "  -c                DBを作成する" 1>&2
      exit 1
      ;;
  esac
done
set -u

docker_compose build
#docker_compose down
# ssh経由でcompose downが動かない問題のワークアラウンド
ssh -t "${SSH_HOST}" -- docker compose -p "${COMPOSE_PROJECT_NAME}" down
if [ "${import}" -eq 1 ]; then
  docker_compose run --rm web rails db:environment:set
  docker_compose run --rm -e DISABLE_DATABASE_ENVIRONMENT_CHECK=1 web rails db:drop
  docker_compose run --rm web rails db:create
  docker_compose up -d db
  (docker_compose exec -T db pg_restore --verbose --clean --if-exists -U postgres -d app_production) < "${backup_file}"
elif [ "${create}" -eq 1 ]; then
  docker_compose run --rm web rails db:create
fi
docker_compose run --rm web rails db:migrate
docker_compose up -d --remove-orphans
