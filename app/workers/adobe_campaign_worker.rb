# frozen_string_literal: true

class AdobeCampaignWorker
  include Sidekiq::Worker

  sidekiq_options unique: :until_and_while_executing

  attr_accessor :form, :params

  def perform(id, params)
    self.form = Form.find(id)
    self.params = params
    return if form.campaign_code.blank?
    find_or_create_adobe_profile
  rescue ActiveRecord::RecordNotFound
    # Form deleted after job enqueued, ignore it
    nil
  end

  def find_or_create_adobe_profile
    @adobe_profile ||= find_on_adobe_campaign
    @adobe_profile ||= post_to_adobe_campaign
  end

  def find_on_adobe_campaign
    Adobe::Campaign::Profile.by_email(email_address)['content'][0]
  end

  def post_to_adobe_campaign
    Adobe::Campaign::Profile.post(profile_hash)
  end

  def find_or_create_adobe_subscription
    find_adobe_subscription || subscribe_to_adobe_campaign
  end

  def find_adobe_subscription
    profile = find_or_create_adobe_profile
    prof_subs_url = profile['subscriptions']['href']
    subscriptions = Adobe::Campaign::Base.get_request(prof_subs_url)['content']
    subscriptions.find { |sub| sub['serviceName'] == form.campaign_code }
  end

  def subscribe_to_adobe_campaign
    profile = find_or_create_adobe_profile
    service_subs_url = adobe_campaign_service['subscriptions']['href']
    Adobe::Campaign::Service.post_subscription(service_subs_url, profile['PKey'])
  end

  def adobe_campaign_service
    Adobe::Campaign::Service.find(form.campaign_code).dig('content', 0)
  end

  def email_address_name
    return @email_address_name if @email_field_set
    @email_field_set = true
    @email_address_name = form.fields.find_by(input: 'email', adobe_campaign_attribute: 'email')&.name
  end

  def email_address
    @email_address ||= params[email_address_name]
  end

  def profile_hash
    profile = {}
    params.each do |key, value|
      field = form.fields.find_by(name: key)
      next if field.adobe_campaign_attribute.blank?
      profile.deep_merge!(hasherize(field.adobe_campaign_attribute.split('.'), value))
    end
    profile
  end

  # Recursively converts 'foo.bar.baz' = value to { foo: { bar: { baz: value } } }
  def hasherize(keys = [], value = nil)
    if keys.empty?
      value
    else
      { keys.shift => hasherize(keys, value) }
    end
  end
end
