
# frozen_string_literal: true

require 'redis'
require 'redis/namespace'

host = ENV.fetch('REDIS_PORT_6379_TCP_ADDR')
Redis.current = Redis::Namespace.new("campaign-forms:#{Rails.env}", redis: Redis.new(host: host))
