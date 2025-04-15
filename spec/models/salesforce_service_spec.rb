# frozen_string_literal: true

require "rails_helper"

RSpec.describe SalesforceService, type: :model do
  describe "get_access_token" do
    it "fetches and caches access token" do
      # Prepare
      access_token = SecureRandom.alphanumeric(30)
      stub_request(:post, "#{SalesforceService::AUTH_BASE_URI}/v2/token")
        .with(
          body: {
            "grant_type" => "client_credentials",
            "client_id" => ENV["SALESFORCE_CLIENT_ID"],
            "client_secret" => ENV["SALESFORCE_CLIENT_SECRET"]
          }.to_json
        )
        .to_return(status: 200, body: { access_token: access_token }.to_json)

      # Test
      result = SalesforceService.get_access_token

      # Verify
      expect(result).to eq(access_token)
    end

    it "returns nil when API call fails" do
      # Prepare
      stub_request(:post, "#{SalesforceService::AUTH_BASE_URI}/v2/token")
        .to_return(status: 500, body: "Internal Server Error")

      # Test
      result = SalesforceService.get_access_token

      # Verify
      expect(result).to be_nil
    end
  end

  describe "send_campaign_subscription" do
    it "sends subscription data to Salesforce" do
      # Prepare
      access_token = SecureRandom.alphanumeric(30)
      allow(SalesforceService).to receive(:get_access_token).and_return(access_token)
      
      email = "test@example.com"
      campaign_name = "Test Campaign"
      data = { "first_name" => "John", "last_name" => "Doe" }
      
      expected_payload = {
        items: [
          {
            keys: {
              email_address: email
            },
            values: {
              email_address: email,
              campaigns: campaign_name,
              first_name: "John",
              last_name: "Doe"
            }
          }
        ]
      }
      
      stub_request(:post, "#{SalesforceService::REST_BASE_URI}/hub/v1/dataevents/key:campaign_forms_data/rowset")
        .with(
          body: expected_payload.to_json,
          headers: {
            "Authorization" => "Bearer #{access_token}",
            "Content-Type" => "application/json"
          }
        )
        .to_return(status: 200, body: "")

      # Test
      result = SalesforceService.send_campaign_subscription(email, campaign_name, data)

      # Verify
      expect(result).to eq(true)
    end

    it "returns false when authentication fails" do
      # Prepare
      allow(SalesforceService).to receive(:get_access_token).and_return(nil)
      
      # Test
      result = SalesforceService.send_campaign_subscription("test@example.com", "Test Campaign")

      # Verify
      expect(result).to eq(false)
    end

    it "returns false when API call fails" do
      # Prepare
      access_token = SecureRandom.alphanumeric(30)
      allow(SalesforceService).to receive(:get_access_token).and_return(access_token)
      
      stub_request(:post, "#{SalesforceService::REST_BASE_URI}/hub/v1/dataevents/key:campaign_forms_data/rowset")
        .to_return(status: 500, body: "Internal Server Error")

      # Test
      result = SalesforceService.send_campaign_subscription("test@example.com", "Test Campaign")

      # Verify
      expect(result).to eq(false)
    end
  end
end 