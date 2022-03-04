#!/bin/bash

PG_PASSWORD="$(date +%s | sha256sum | base64 | head -c 16)"
docker run --rm --network=$DOCKER_NETWORK --name=$PROJECT_NAME-redis -d redis
docker run --rm --network=$DOCKER_NETWORK --name=$PROJECT_NAME-pg -e POSTGRES_PASSWORD=$PG_PASSWORD -d postgres:13
sleep 10

REDIS_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $PROJECT_NAME-redis)
PG_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $PROJECT_NAME-pg)

docker buildx build $DOCKER_ARGS \
    --build-arg PROJECT_NAME=$PROJECT_NAME \
    --build-arg SIDEKIQ_CREDS=$SIDEKIQ_CREDS \
    --build-arg DD_API_KEY=$DD_API_KEY \
    --build-arg SESSION_REDIS_HOST=$REDIS_IP \
    --build-arg STORAGE_REDIS_HOST=$REDIS_IP \
    --build-arg DB_ENV_POSTGRESQL_USER=postgres \
    --build-arg DB_ENV_POSTGRESQL_PASS=$PG_PASSWORD \
    --build-arg DB_PORT_5432_TCP_ADDR=$PG_IP \
    --build-arg SITE_URL=$SITE_URL \
    .
rc=$?

docker stop $PROJECT_NAME-redis $PROJECT_NAME-pg

if [ $rc -ne 0 ]; then
  echo -e "Docker build failed"
  exit $rc
fi
