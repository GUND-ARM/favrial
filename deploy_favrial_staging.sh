#!/bin/sh

set -eu

. staging.env

export SSH_HOST
export COMPOSE_PROJECT_NAME
export APP_WEB_PORT
export SECRET_KEY_BASE
export TWITTER_CLIENT_ID
export TWITTER_CLIENT_SECRET

sh deploy.sh "$@"
