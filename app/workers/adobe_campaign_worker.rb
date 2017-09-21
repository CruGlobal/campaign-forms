# frozen_string_literal: true

class AdobeCampaignWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_and_while_executing

  attr_accessor :campaign, :person

  def self.unique_args(args)
    # Only use campaign and email_address in uniqueness
    [args[0], args[1]['email_address']]
  end

  def perform(campaign, person_attrs)
    self.campaign = campaign
    self.person = Person.new(person_attrs)
    find_or_create_adobe_profile
  end

  def find_or_create_adobe_profile
    @adobe_profile ||= find_on_adobe_campaign
    @adobe_profile ||= post_to_adobe_campaign
  end

  def find_on_adobe_campaign
    Adobe::Campaign::Profile.by_email(person.email_address)['content'][0]
  end

  def post_to_adobe_campaign
    profile_hash = {
      'email': person.email_address
    }
    profile_hash['firstName'] = person.first_name if person.first_name.present?
    profile_hash['lastName'] = person.last_name if person.last_name.present?
    Adobe::Campaign::Profile.post(profile_hash)
  end

  def find_or_create_adobe_subscription
    find_adobe_subscription || subscribe_to_adobe_campaign
  end

  def find_adobe_subscription
    profile = find_or_create_adobe_profile
    prof_subs_url = profile['subscriptions']['href']
    subscriptions = Adobe::Campaign::Base.get_request(prof_subs_url)['content']
    subscriptions.find { |sub| sub['serviceName'] == campaign }
  end

  def subscribe_to_adobe_campaign
    profile = find_or_create_adobe_profile
    service_subs_url = adobe_campaign_service['subscriptions']['href']
    Adobe::Campaign::Service.post_subscription(service_subs_url, profile['PKey'])
  end

  def adobe_campaign_service
    Adobe::Campaign::Service.find(campaign).dig('content', 0)
  end
end
