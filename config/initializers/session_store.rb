# frozen_string_literal: true

require 'redis'

redis_conf = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'redis.yml'))).result, [], [], true)['session']

Rails.application.config.session_store :redis_store, servers: [redis_conf], expire_after: 2.hours
