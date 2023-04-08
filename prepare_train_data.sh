#!/bin/sh

line_limit=20000

set -eu

. production.env
#. staging.env

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

# 現在の日時を取得
timestamp=$(date '+%Y%m%d%H%M%S')

mkdir -p train_data/sulemio
mkdir -p train_data/notsulemio

# 画像URLの一覧を取得
docker_compose run -e MEDIA_URLS_LINE_LIMIT="${line_limit}" --rm web rails media_urls:sulemio > train_data/sulemio.txt
docker_compose run -e MEDIA_URLS_LINE_LIMIT="${line_limit}" --rm web rails media_urls:notsulemio > train_data/notsulemio.txt

# 画像URLの一覧から画像をダウンロード
cat train_data/sulemio.txt | while read -r l; do
  file="$(echo "${l}" | awk -F '/' '{print $NF}')"
  if test -f train_data/sulemio/"${file}"; then
    echo "${file} exits. skip."
  else
    curl --remote-name --output-dir train_data/sulemio "${l}"
  fi
done
cat train_data/notsulemio.txt | while read -r l; do
  file="$(echo "${l}" | awk -F '/' '{print $NF}')"
  if test -f train_data/notsulemio/"${file}"; then
    echo "${file} exits. skip."
  else
    curl --remote-name --output-dir train_data/notsulemio "${l}"
  fi
done

# 0バイトのファイルを削除
find train_data -type f -empty -delete

# train_data をtgzに圧縮
tar -czvf "train_data-${timestamp}.tgz" train_data
