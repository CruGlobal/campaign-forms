FROM 056154071827.dkr.ecr.us-east-1.amazonaws.com/base-image-ruby-version-arg:2.4
MAINTAINER cru.org <wmd@cru.org>

# Upgrade nodejs and npm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.1.0

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
  && \. "$NVM_DIR/nvm.sh" \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install yarn
#RUN curl -o- -L https://yarnpkg.com/install.sh | bash \
#  && ln -nsf /rails/.yarn/bin/yarn /usr/local/bin/yarn
RUN npm install yarn -g \
  && export PATH="$PATH:`yarn global bin`"

ARG SIDEKIQ_CREDS
ARG RAILS_ENV=production

COPY Gemfile Gemfile.lock ./

RUN bundle config gems.contribsys.com $SIDEKIQ_CREDS
RUN bundle install --jobs 20 --retry 5 --path vendor
RUN bundle binstub puma sidekiq rake

COPY . ./

ARG ROLLBAR_ACCESS_TOKEN=asdf
ARG REDIS_PORT_6379_TCP_ADDR
ARG REDIS_PORT_6379_TCP_ADDR_SESSION
ARG DISABLE_ROLLBAR=true
ARG SECRET_KEY_BASE=asdf
ARG DB_ENV_POSTGRESQL_USER
ARG DB_ENV_POSTGRESQL_PASS
ARG DB_PORT_5432_TCP_ADDR

RUN bundle exec rake assets:clobber assets:precompile RAILS_ENV=production

# Run this last to make sure permissions are all correct
RUN mkdir -p /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads && \
  chmod -R ugo+rw /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads
