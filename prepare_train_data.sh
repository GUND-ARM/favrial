#!/bin/sh

line_limit=10000
test_data_count=100

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

rm -rf train_data
mkdir train_data
mkdir train_data/sulemio
mkdir train_data/notsulemio
mkdir train_data/sulemio/train
mkdir train_data/sulemio/test
mkdir train_data/notsulemio/train
mkdir train_data/notsulemio/test

# 画像URLの一覧を取得
docker_compose run -e MEDIA_URLS_LINE_LIMIT="${line_limit}" --rm web rails media_urls:sulemio > train_data/sulemio.txt
docker_compose run -e MEDIA_URLS_LINE_LIMIT="${line_limit}" --rm web rails media_urls:notsulemio > train_data/notsulemio.txt

# 画像URLの一覧から画像をダウンロード
cat train_data/sulemio.txt | xargs -IXXX curl --remote-name --output-dir train_data/sulemio/train XXX
cat train_data/notsulemio.txt | xargs -IXXX curl --remote-name --output-dir train_data/notsulemio/train XXX

# 0バイトのファイルを削除
find train_data -type f -empty -delete

# train から test_data_count 件ずつ test に移動
find train_data/sulemio/train -type f | head -n "${test_data_count}" | xargs -IXXX mv XXX train_data/sulemio/test
find train_data/notsulemio/train -type f | head -n "${test_data_count}" | xargs -IXXX mv XXX train_data/notsulemio/test
