# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdobeCampaignWorker do
  before(:each) do
    @access_token = SecureRandom.alphanumeric(30)
    @stub = stub_request(:post, "https://ims-na1.adobelogin.com/ims/token/v3")
      .with(body: {"client_id" => "asdf", "client_secret" => "asdf", "grant_type" => "client_credentials",
                   "scope" => "campaign_sdk, openid, deliverability_service_general, campaign_config_server_general, AdobeID, additional_info.projectedProductContext"})
      .to_return(status: 200, body: {access_token: @access_token}.to_json)
  end

  describe "perform" do
    it "performs job" do
      # Prepare
      form = create(:form)
      params = {}
      campaign_code = SecureRandom.alphanumeric(10)
      subscription_url = Faker::Internet.url
      stub_request(:get, subscription_url)
        .to_return(status: 200, body: {content: [{serviceName: campaign_code}]}.to_json)

      # noinspection RubyStringKeysInHashInspection
      adobe_profile = {
        "subscriptions" => {"href" => subscription_url}
      }
      # noinspection RubyStringKeysInHashInspection
      by_email_payload = {
        "content" => [adobe_profile]
      }
      expect(Adobe::Campaign::Profile).to receive(:by_email).and_return(by_email_payload)

      master_person_id = SecureRandom.rand(1_000_000)
      campaign_worker = AdobeCampaignWorker.new

      # Test
      campaign_worker.perform(form.id, params, campaign_code, master_person_id)

      # Verify
      expect(campaign_worker.form).to eq(form)
      expect(campaign_worker.params).to eq(params)
      expect(campaign_worker.campaign_codes).to eq([campaign_code])
      expect(campaign_worker.master_person_id).to eq(master_person_id)
      expect(campaign_worker.instance_variable_get(:@adobe_profile)).to eq(adobe_profile)
    end

    it "supports multiple campaign_codes" do
      # Prepare
      form = create(:form)
      params = {}
      campaign_codes = [SecureRandom.alphanumeric(10), SecureRandom.alphanumeric(10)]
      subscription_url = Faker::Internet.url
      stub_request(:get, subscription_url)
        .to_return(status: 200, body: {content: [{serviceName: campaign_codes[0]},
          {serviceName: campaign_codes[1]}]}.to_json)

      # noinspection RubyStringKeysInHashInspection
      adobe_profile = {
        "subscriptions" => {"href" => subscription_url}
      }
      # noinspection RubyStringKeysInHashInspection
      by_email_payload = {
        "content" => [adobe_profile]
      }
      expect(Adobe::Campaign::Profile).to receive(:by_email).and_return(by_email_payload)

      master_person_id = SecureRandom.rand(1_000_000)
      campaign_worker = AdobeCampaignWorker.new

      # Test
      campaign_worker.perform(form.id, params, campaign_codes, master_person_id)

      # Verify
      expect(campaign_worker.form).to eq(form)
      expect(campaign_worker.params).to eq(params)
      expect(campaign_worker.campaign_codes).to eq(campaign_codes)
      expect(campaign_worker.master_person_id).to eq(master_person_id)
      expect(campaign_worker.instance_variable_get(:@adobe_profile)).to eq(adobe_profile)
    end

    it "should do nothing if the form does not exist" do
      # Prepare
      params = {}
      campaign_code = SecureRandom.alphanumeric(10)
      master_person_id = SecureRandom.rand(1_000_000)
      campaign_worker = AdobeCampaignWorker.new

      # Test
      result = campaign_worker.perform(15, params, campaign_code, master_person_id)

      # Verify
      expect(result).to eq(nil)
      expect(campaign_worker.params).to eq(nil)
    end

    it "should raise error when Rest API returns error" do
      # Prepare
      form = create(:form)
      expect(Adobe::Campaign::Profile).to receive(:by_email).and_raise(RestClient::GatewayTimeout.new)

      params = {}
      campaign_code = SecureRandom.alphanumeric(10)

      master_person_id = SecureRandom.rand(1_000_000)
      campaign_worker = AdobeCampaignWorker.new

      # Test and verify
      expect {
        campaign_worker.perform(form.id, params, campaign_code, master_person_id)
      }.to raise_exception(IgnorableError)
    end
  end

  describe "find_or_create_adobe_profile" do
    it "should skip 'find_on_adobe_campaign' when 'form.create_profile?' is set" do
      form = create(:form, create_profile: true)
      campaign_worker = AdobeCampaignWorker.new
      campaign_worker.form = form
      expect(campaign_worker).not_to receive(:find_on_adobe_campaign)
      expect(campaign_worker).to receive(:post_to_adobe_campaign)
      campaign_worker.find_or_create_adobe_profile
    end

    it "should call 'find_on_adobe_campaign' when 'form.create_profile?' is not set" do
      form = create(:form)
      campaign_worker = AdobeCampaignWorker.new
      campaign_worker.form = form
      expect(campaign_worker).to receive(:find_on_adobe_campaign)
      expect(campaign_worker).to receive(:post_to_adobe_campaign)
      campaign_worker.find_or_create_adobe_profile
    end
  end

  describe "post_to_adobe_campaign" do
    it "should call Adobe::Campaign::Profile.post" do
      # Prepare
      form = create(:form)
      campaign_worker = AdobeCampaignWorker.new
      campaign_worker.perform(form.id, {}, nil, nil)
      profile_hash = {email_address: {email: "some_email"}}
      expect(campaign_worker).to receive(:profile_hash).and_return(profile_hash)
      stub_request(:post, "https://mc.adobe.io/cru/campaign/profileAndServicesExt/profile")
        .with(body: profile_hash.to_json)
        .to_return(status: 200, body: '{"result": "something"}')

      # Test
      result = campaign_worker.post_to_adobe_campaign

      # Verify
      # noinspection RubyStringKeysInHashInspection
      expect(result).to eq("result" => "something")
    end
  end

  describe "profile_hash" do
    it "skips for non adobe_campaign_attribute" do
      # Prepare
      form = create(:form)
      field = create(:email_field)
      create(:form_field, form: form, field: field)
      campaign_worker = AdobeCampaignWorker.new
      campaign_worker.perform(form.id, {}, nil, nil)

      # Test
      result = campaign_worker.profile_hash

      # Verify
      expect(result).to eq({})
    end

    it "skips values that are blank" do
      # Prepare
      form = create(:form)
      field = create(:state_field, adobe_campaign_attribute: "State")
      create(:form_field, form: form, field: field)
      campaign_worker = AdobeCampaignWorker.new
      params = {
        field.name => "AA"
      }
      campaign_worker.perform(form.id, params, nil, nil)

      # Test
      result = campaign_worker.profile_hash

      # Verify
      # noinspection RubyStringKeysInHashInspection
      expect(result).to eq({})
    end

    it "sets fields" do
      # Prepare
      form = create(:form)
      field = create(:email_field, adobe_campaign_attribute: "email_address.email")
      create(:form_field, form: form, field: field)
      campaign_worker = AdobeCampaignWorker.new
      new_value = SecureRandom.alphanumeric(30)
      params = {
        field.name => new_value
      }
      campaign_worker.perform(form.id, params, nil, nil)

      # Test
      result = campaign_worker.profile_hash

      # Verify
      # noinspection RubyStringKeysInHashInspection
      expect(result).to eq("email_address" => {"email" => new_value})
    end

    it "skips sets master_person_id" do
      # Prepare
      master_person_id = SecureRandom.rand(1_000_000)
      form = create(:form)
      campaign_worker = AdobeCampaignWorker.new
      campaign_worker.perform(form.id, {}, nil, master_person_id)

      # Test
      result = campaign_worker.profile_hash

      # Verify
      # noinspection RubyStringKeysInHashInspection
      expect(result).to eq(AdobeCampaignWorker::MASTER_PERSON_ID => master_person_id)
    end
  end

  describe "value_for_key" do
    it "returns downcase if this is an email" do
      # Prepare
      form = create(:form)
      field = create(:email_field, adobe_campaign_attribute: "email")
      create(:form_field, form: form, field: field)
      campaign_worker = AdobeCampaignWorker.new
      campaign_worker.perform(form.id, {}, nil, nil)
      value = SecureRandom.alphanumeric(30)

      # Test
      result = campaign_worker.value_for_key(value, field.name)

      # Verify
      expect(result).to eq(value.downcase)
    end

    it "returns just value if this is not email" do
      # Prepare
      form = create(:form)
      campaign_worker = AdobeCampaignWorker.new
      campaign_worker.perform(form.id, {}, nil, nil)
      value = SecureRandom.alphanumeric(30)

      # Test
      result = campaign_worker.value_for_key(value, "anything")

      # Verify
      expect(result).to eq(value)
    end
  end

  describe "hasherize" do
    it "converts recursively" do
      # Prepare
      campaign_worker = AdobeCampaignWorker.new
      keys = %w[foo bar baz]
      value = SecureRandom.alphanumeric(10)

      # Test
      result = campaign_worker.hasherize(keys, value)

      # Verify
      # noinspection RubyStringKeysInHashInspection
      expect(result).to eq("foo" => {"bar" => {"baz" => value}})
    end
  end
end
