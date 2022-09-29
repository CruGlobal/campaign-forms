FROM public.ecr.aws/docker/library/ruby:3.0-alpine

LABEL com.datadoghq.ad.logs='[{"source": "ruby"}]'

ARG SIDEKIQ_CREDS
ARG RAILS_ENV=production

# Upgrade alpine packages (useful for security fixes)
RUN apk upgrade --no-cache

# Install rails/app dependencies
RUN apk --no-cache add libc6-compat git postgresql-libs tzdata nodejs yarn

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

# Install bundler version which created the lock file
RUN gem install bundler -v $(awk '/^BUNDLED WITH/ { getline; print $1; exit }' Gemfile.lock)
RUN bundle config gems.contribsys.com $SIDEKIQ_CREDS

# Install build-dependencies, then install gems, subsequently removing build-dependencies
RUN apk --no-cache add --virtual build-deps build-base postgresql-dev \
    && bundle install --jobs 20 --retry 2 \
    && apk del build-deps

# Copy the application
COPY . .

ARG PROJECT_NAME
ARG ROLLBAR_ACCESS_TOKEN=asdf
ARG SESSION_REDIS_DB_INDEX=1
ARG SESSION_REDIS_HOST
ARG SESSION_REDIS_PORT=6379
ARG STORAGE_REDIS_DB_INDEX=1
ARG STORAGE_REDIS_HOST
ARG STORAGE_REDIS_PORT=6379
ARG DISABLE_ROLLBAR=true
ARG SECRET_KEY_BASE=asdf
ARG DB_ENV_POSTGRESQL_USER
ARG DB_ENV_POSTGRESQL_PASS
ARG DB_PORT_5432_TCP_ADDR
ARG SITE_URL

# Compile assets
RUN RAILS_ENV=production bundle exec rake assets:clobber assets:precompile

# Define volumes used by ECS to share public html and extra nginx config with nginx container
VOLUME /usr/src/app/public
VOLUME /usr/src/app/nginx-conf

# Command to start rails
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
