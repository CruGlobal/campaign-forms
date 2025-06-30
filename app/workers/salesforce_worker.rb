# frozen_string_literal: true

class SalesforceWorker
  include Sidekiq::Worker

  MASTER_PERSON_ID = "master_person_id"

  sidekiq_options lock: :until_and_while_executing

  attr_accessor :form, :params, :master_person_id, :campaign_codes

  def perform(id, params, campaign_codes, master_person_id = nil)
    self.form = Form.find(id)
    self.params = params
    self.campaign_codes = Array.wrap(campaign_codes)
    self.master_person_id = master_person_id
    return if self.campaign_codes.empty?

    self.campaign_codes.each { |campaign_code| send_to_salesforce(campaign_code) }
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

  def send_to_salesforce(campaign_code)
    SalesforceService.send_campaign_subscription(email_address, campaign_code, salesforce_data)
  rescue => e
    # Log error but don't fail the job
    Rails.logger.error("Failed to send to Salesforce: #{e.message}")
    nil
  end

  def email_address_name
    return @email_address_name if @email_field_set
    @email_field_set = true
    @email_address_name = form.fields.find_by(input: "email", salesforce_attribute: "email_address")&.name
  end

  def email_address
    @email_address ||= params[email_address_name]&.downcase
  end

  def prefer_not_to_say(key, value)
    %w[Country State].include?(key) && value == "AA"
  end

  def value_for_key(value, key)
    return value.downcase if key == email_address_name

    value
  end

  def salesforce_data
    salesforce_data = {}
    params.each do |key, value|
      field = form.fields.find_by(name: key)

      next if !field || field.salesforce_attribute.blank? || prefer_not_to_say(key, value)

      salesforce_data[key] = value
    end
    salesforce_data[MASTER_PERSON_ID] = master_person_id if master_person_id.present?

    salesforce_data.stringify_keys
  end
end
