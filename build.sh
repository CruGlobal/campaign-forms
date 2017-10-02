#!/bin/bash

docker build \
    --build-arg SIDEKIQ_CREDS=$SIDEKIQ_CREDS \
    --build-arg REDIS_PORT_6379_TCP_ADDR=$REDIS_PORT_6379_TCP_ADDR \
    --build-arg REDIS_PORT_6379_TCP_ADDR_SESSION=$REDIS_PORT_6379_TCP_ADDR_SESSION \
    --build-arg DB_ENV_POSTGRESQL_USER=$DB_ENV_POSTGRESQL_USER \
    --build-arg DB_ENV_POSTGRESQL_PASS=$DB_ENV_POSTGRESQL_PASS \
    --build-arg DB_PORT_5432_TCP_ADDR=$DB_PORT_5432_TCP_ADDR \
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$GIT_COMMIT-$BUILD_NUMBER .
rc=$?

if [ $rc -ne 0 ]; then
  echo -e "Docker build failed"
  exit $rc
fi
