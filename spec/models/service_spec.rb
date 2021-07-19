# frozen_string_literal: true

require "rails_helper"

RSpec.describe Service, type: :model do
  describe "all" do
    before(:each) do
      @access_token = SecureRandom.alphanumeric(20)
    end
    it "fetches services with two requests" do
      # Prepare
      stub_request(:post, "https://ims-na1.adobelogin.com/ims/exchange/jwt")
        .with(body: {client_id: "asdf", client_secret: "asdf", jwt_token: "asdf"})
        .to_return(status: 200, body: {access_token: @access_token}.to_json)

      services1 = [1, 2, 3]
      services2 = [4, 5, 6]
      stub_request(:get, "https://mc.adobe.io/cru/campaign/profileAndServices/service")
        .with(headers: {Authorization: "Bearer #{@access_token}"})
        .to_return(status: 200, body: {content: services1, next: {href: "profileAndServices/service2"}}.to_json)
      stub_request(:get, "https://mc.adobe.io/cru/campaign/profileAndServices/service2")
        .with(headers: {Authorization: "Bearer #{@access_token}"})
        .to_return(status: 200, body: {content: services2}.to_json)

      # Test
      result = Service.all

      # Verify
      expect(result).to eq(services1.concat(services2))
    end
  end

  describe "active_admin_collection" do
    it "returns the collection" do
      # Prepare
      # noinspection RubyStringKeysInHashInspection
      all_services = [
        {"label" => "label1", "name" => "name1"},
        {"label" => "label2", "name" => "name2"},
        {"label" => "label3", "name" => "name3"}
      ]
      expect(Service).to receive(:all).and_return(all_services)

      # Test
      result = Service.active_admin_collection

      # Verify
      expected_result = {
        "label1" => "name1",
        "label2" => "name2",
        "label3" => "name3"
      }
      expect(result).to eq(expected_result)
    end
  end

  describe "post_subscription" do
    it "posts subscription with origin" do
      # Prepare
      service_subs_url = Faker::Internet.url
      person_pkey = SecureRandom.alphanumeric(20)
      # noinspection RubyStringKeysInHashInspection
      stub_request(:post, service_subs_url)
        .with(body: {"subscriber" => {"PKey" => person_pkey}})
        .to_return(status: 200, body: '{"success": true}')

      # Test
      result = Service.post_subscription(service_subs_url, person_pkey)
      # Verify
      expect(result).to eq("success" => true)
    end
  end
end
