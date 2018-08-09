# frozen_string_literal: true

class Service < Adobe::Campaign::Service
  def self.all
    Rails.cache.fetch('adobe_campaign_services', expires_in: 30.minutes) do
      result = super
      services = result['content'] || []
      loop do
        break unless result['next']
        result = get_request(result['next']['href'])
        services.concat(result['content'] || [])
      end
      services
    end
  end

  def self.active_admin_collection
    all.map { |service| service.values_at('label', 'name') }.sort {|a, b| a.first <=> b.first}.to_h
  end
end
