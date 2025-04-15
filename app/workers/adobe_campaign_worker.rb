# frozen_string_literal: true

class AdobeCampaignWorker
  include Sidekiq::Worker

  MASTER_PERSON_ID = 'cusGlobalID'

  sidekiq_options lock: :until_and_while_executing

  attr_accessor :form, :params, :master_person_id, :campaign_codes

  def perform(id, params, campaign_codes, master_person_id = nil)
    self.form = Form.find(id)
    self.params = params
    self.campaign_codes = Array.wrap(campaign_codes)
    self.master_person_id = master_person_id
    return if self.campaign_codes.empty?

    find_or_create_adobe_profile
    self.campaign_codes.each { |campaign_code| find_or_create_adobe_subscription(campaign_code) }
  rescue ActiveRecord::RecordNotFound
    # Form deleted after job enqueued, ignore it
    nil
  rescue RestClient::ServiceUnavailable,
         RestClient::GatewayTimeout,
         RestClient::BadGateway,
         RestClient::InternalServerError
    # Ignore ServiceUnavailable, sidekiq will retry
    raise IgnorableError
  end

  def find_or_create_adobe_profile
    # First try to find the profile, unless we should always create one
    @adobe_profile ||= find_on_adobe_campaign unless form.create_profile?
    @find_or_create_adobe_profile ||= post_to_adobe_campaign
  end

  def find_on_adobe_campaign
    Adobe::Campaign::Profile.by_email(email_address)['content'][0]
  end

  def post_to_adobe_campaign
    Adobe::Campaign::Profile.post(profile_hash)
  end

  def find_or_create_adobe_subscription(campaign_code)
    find_adobe_subscription(campaign_code) || subscribe_to_adobe_campaign(campaign_code)
  end

  def find_adobe_subscription(campaign_code)
    profile = find_or_create_adobe_profile
    prof_subs_url = profile['subscriptions']['href']
    subscriptions = Adobe::Campaign::Base.get_request(prof_subs_url)['content']
    subscriptions.find { |sub| sub['serviceName'] == campaign_code }
  end

  def subscribe_to_adobe_campaign(campaign_code)
    profile = find_or_create_adobe_profile
    service_subs_url = adobe_campaign_service(campaign_code)['subscriptions']['href']
    adobe_result = Service.post_subscription(service_subs_url, profile['PKey'], form.origin)

    # Also send the subscription to Salesforce
    send_to_salesforce(campaign_code)

    adobe_result
  end

  def send_to_salesforce(campaign_code)
    return unless email_address

    additional_data = {
      'first_name' => extract_field_value('first_name'),
      'last_name' => extract_field_value('last_name'),
      'master_person_id' => master_person_id
    }

    # Filter out nil values
    additional_data.compact!

    SalesforceService.send_campaign_subscription(email_address, campaign_code, additional_data)
  rescue StandardError => e
    # Log error but don't fail the job
    Rails.logger.error("Failed to send to Salesforce: #{e.message}")
    nil
  end

  def extract_field_value(attribute_name)
    field = form.fields.find_by(global_registry_attribute: attribute_name)
    field ? params[field.name] : nil
  end

  def adobe_campaign_service(campaign_code)
    Adobe::Campaign::Service.find(campaign_code).dig('content', 0)
  end

  def email_address_name
    return @email_address_name if @email_field_set

    @email_field_set = true
    @email_address_name = form.fields.find_by(input: 'email', adobe_campaign_attribute: 'email')&.name
  end

  def email_address
    @email_address ||= params[email_address_name]&.downcase
  end

  def prefer_not_to_say(key, value)
    %w[Country State].include?(key) && value == 'AA'
  end

  def profile_hash
    profile = {}
    params.each do |key, value|
      field = form.fields.find_by(name: key)

      next if field.adobe_campaign_attribute.blank? || prefer_not_to_say(key, value)

      profile.deep_merge!(hasherize(field.adobe_campaign_attribute.split('.'), value_for_key(value, key)))
    end
    profile[MASTER_PERSON_ID] = master_person_id if master_person_id.present?
    profile
  end

  def value_for_key(value, key)
    return value.downcase if key == email_address_name

    value
  end

  # Recursively converts ['foo', 'bar', 'baz'] = value to { foo: { bar: { baz: value } } }
  def hasherize(keys = [], value = nil)
    if keys.empty?
      value
    else
      { keys.shift => hasherize(keys, value) }
    end
  end
end
