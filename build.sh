#!/bin/bash

PG_PASSWORD="$(date +%s | sha256sum | base64 | head -c 16)"
docker network create $PROJECT_NAME
docker run --rm --network=$PROJECT_NAME --name=$PROJECT_NAME-redis -d redis
docker run --rm --network=$PROJECT_NAME --name=$PROJECT_NAME-pg -e POSTGRES_PASSWORD=$PG_PASSWORD -d postgres:11
sleep 10

docker build \
    --network $PROJECT_NAME \
    --build-arg PROJECT_NAME=$PROJECT_NAME \
    --build-arg SIDEKIQ_CREDS=$SIDEKIQ_CREDS \
    --build-arg DD_API_KEY=$DD_API_KEY \
    --build-arg REDIS_PORT_6379_TCP_ADDR=$PROJECT_NAME-redis \
    --build-arg REDIS_PORT_6379_TCP_ADDR_SESSION=$PROJECT_NAME-redis \
    --build-arg DB_ENV_POSTGRESQL_USER=postgres \
    --build-arg DB_ENV_POSTGRESQL_PASS=$PG_PASSWORD \
    --build-arg DB_PORT_5432_TCP_ADDR=$PROJECT_NAME-pg \
    --build-arg SITE_URL=$SITE_URL
    -t 056154071827.dkr.ecr.us-east-1.amazonaws.com/$PROJECT_NAME:$ENVIRONMENT-$BUILD_NUMBER .
rc=$?

docker stop $PROJECT_NAME-redis $PROJECT_NAME-pg
docker network rm $PROJECT_NAME

if [ $rc -ne 0 ]; then
  echo -e "Docker build failed"
  exit $rc
fi
