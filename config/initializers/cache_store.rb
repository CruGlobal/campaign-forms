# frozen_string_literal: true

require 'redis'

redis_conf = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'redis.yml'))).result, [], [], true)['cache']

Rails.application.config.cache_store = :redis_store, redis_conf