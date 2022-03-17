#!/bin/sh

#
# celery-exporter entrypoint for cloudigrade.
#

if [ -z "${ACG_CONFIG}" ]; then
  export REDIS_USERNAME=${REDIS_USERNAME:-""}
  export REDIS_PASSWORD=${REDIT_PASSWORD:-""}
  export REDIS_HOST=${REDIS_HOST:-"localhost"}
  export REDIS_PORT=${REDIS_PORT:-"6379"}
  export METRICS_PORT=${CELERY_METRICS_PORT:-"9808"}
else
  export REDIS_USERNAME="`cat $ACG_CONFIG | jq -r '.inMemoryDb.username // empty'`"
  export REDIS_PASSWORD="`cat $ACG_CONFIG | jq -r '.inMemoryDb.password // empty'`"
  export REDIS_HOST="`cat $ACG_CONFIG | jq -r '.inMemoryDb.hostname // empty'`"
  export REDIS_PORT="`cat $ACG_CONFIG | jq -r '.inMemoryDb.port // empty'`"
  export METRICS_PORT=`cat $ACG_CONFIG | jq -r '.endpoints[] | select(.app == "cloudigrade" and .name == "metrics").port'`
fi


REDIS_AUTH=""
if [ -n "${REDIS_PASSWORD}" ]; then
  REDIS_AUTH="${REDIS_USERNAME}:${REDIS_PASSWORD}@"
fi
REDIS_URL="redis://${REDIS_AUTH}${REDIS_HOST}:${REDIS_PORT}"

LOG_LEVEL="INFO"
if [ -n "${CELERY_METRICS_LOG_LEVEL}" ]; then
  LOG_LEVEL="${CELERY_METRICS_LOG_LEVEL}"
fi

python /app/cli.py --port ${METRICS_PORT} --broker-url "${REDIS_URL}" --log-level "${LOG_LEVEL}"

