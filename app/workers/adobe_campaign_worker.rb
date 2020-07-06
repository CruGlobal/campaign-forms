# frozen_string_literal: true

class AdobeCampaignWorker
  include Sidekiq::Worker

  MASTER_PERSON_ID = "cusGlobalID"

  sidekiq_options unique: :until_and_while_executing

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
    @adobe_profile ||= post_to_adobe_campaign
  end

  def find_on_adobe_campaign
    Adobe::Campaign::Profile.by_email(email_address)["content"][0]
  end

  def post_to_adobe_campaign
    Adobe::Campaign::Profile.post(profile_hash)
  end

  def find_or_create_adobe_subscription(campaign_code)
    find_adobe_subscription(campaign_code) || subscribe_to_adobe_campaign(campaign_code)
  end

  def find_adobe_subscription(campaign_code)
    profile = find_or_create_adobe_profile
    prof_subs_url = profile["subscriptions"]["href"]
    subscriptions = Adobe::Campaign::Base.get_request(prof_subs_url)["content"]
    subscriptions.find { |sub| sub["serviceName"] == campaign_code }
  end

  def subscribe_to_adobe_campaign(campaign_code)
    profile = find_or_create_adobe_profile
    service_subs_url = adobe_campaign_service(campaign_code)["subscriptions"]["href"]
    Service.post_subscription(service_subs_url, profile["PKey"], form.origin)
  end

  def adobe_campaign_service(campaign_code)
    Adobe::Campaign::Service.find(campaign_code).dig("content", 0)
  end

  def email_address_name
    return @email_address_name if @email_field_set
    @email_field_set = true
    @email_address_name = form.fields.find_by(input: "email", adobe_campaign_attribute: "email")&.name
  end

  def email_address
    @email_address ||= params[email_address_name]&.downcase
  end

  def profile_hash
    profile = {}
    params.each do |key, value|
      field = form.fields.find_by(name: key)

      next if field.adobe_campaign_attribute.blank? || value.blank?
      profile.deep_merge!(hasherize(field.adobe_campaign_attribute.split("."), value_for_key(value, key)))
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
      {keys.shift => hasherize(keys, value)}
    end
  end
end
