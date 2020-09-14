FROM 056154071827.dkr.ecr.us-east-1.amazonaws.com/base-image-ruby-version-arg:2.6
MAINTAINER cru.org <wmd@cru.org>

ARG SIDEKIQ_CREDS
ARG RAILS_ENV=production
ARG SESSION_REDIS_DB_INDEX=1
ARG SESSION_REDIS_HOST
ARG SESSION_REDIS_PORT=6379
ARG STORAGE_REDIS_DB_INDEX=1
ARG STORAGE_REDIS_HOST
ARG STORAGE_REDIS_PORT=6379

# Config for logging to datadog
ARG DD_API_KEY
RUN DD_AGENT_MAJOR_VERSION=7 DD_INSTALL_ONLY=true DD_API_KEY=$DD_API_KEY bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh)"
COPY docker/datadog-agent /etc/datadog-agent
COPY docker/supervisord-datadog.conf /etc/supervisor/conf.d/supervisord-datadog.conf
COPY docker/docker-entrypoint.sh /

COPY Gemfile Gemfile.lock ./

RUN bundle config gems.contribsys.com $SIDEKIQ_CREDS
RUN bundle install --jobs 20 --retry 5 --path vendor
RUN bundle binstub puma sidekiq rake

COPY . ./

ARG PROJECT_NAME
ARG ROLLBAR_ACCESS_TOKEN=asdf
ARG REDIS_PORT_6379_TCP_ADDR
ARG REDIS_PORT_6379_TCP_ADDR_SESSION
ARG DISABLE_ROLLBAR=true
ARG SECRET_KEY_BASE=asdf
ARG DB_ENV_POSTGRESQL_USER
ARG DB_ENV_POSTGRESQL_PASS
ARG DB_PORT_5432_TCP_ADDR
ARG SITE_URL

RUN bundle exec rake assets:clobber assets:precompile RAILS_ENV=production

# Run this last to make sure permissions are all correct
RUN mkdir -p /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads && \
  chmod -R ugo+rw /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads

CMD "/docker-entrypoint.sh"
