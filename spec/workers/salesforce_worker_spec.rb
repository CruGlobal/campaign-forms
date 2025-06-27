# frozen_string_literal: true

require "rails_helper"

RSpec.describe SalesforceWorker do
  before do
    @access_token = SecureRandom.alphanumeric(30)

    stub_request(:post, "#{ENV["SALESFORCE_AUTH_URI"]}/v2/token")
      .with(body: "{\"grant_type\":\"client_credentials\",\"client_id\":\"your_client_id\",\"client_secret\":\"your_client_secret\"}")
      .to_return(status: 200, body: {"access_token" => "12345"}.to_json, headers: {})
  end

  describe "perform" do
    it "should include available profile data" do
      # Prepare
      form = create(:form)
      email_field = create(:field, input: "email", name: "email_address", adobe_campaign_attribute: "email", salesforce_attribute: "email_address")
      first_name_field = create(:field, name: "first_name", global_registry_attribute: "first_name", adobe_campaign_attribute: "first_name", salesforce_attribute: "first_name")
      last_name_field = create(:field, name: "last_name", global_registry_attribute: "last_name", adobe_campaign_attribute: "last_name")

      create(:form_field, form: form, field: email_field)
      create(:form_field, form: form, field: first_name_field)
      create(:form_field, form: form, field: last_name_field)

      campaign_code = "test_campaign"
      email = "test@example.com"
      first_name = "John"
      last_name = "Doe"
      master_person_id = "12345"

      salesforce_worker = SalesforceWorker.new
      params = {"email_address" => email, "first_name" => first_name, "last_name" => last_name}

      # add expects here
      stub_request(:post, "https://uid.rest.marketingcloudapis.com/hub/v1/dataevents/key:sfmc_de_external_key/rowset")
        .with(
          body: "[{\"keys\":{\"subscriberkey\":\"test@example.com\",\"campaigns\":\"test_campaign\"},\"values\":{\"subscriberkey\":\"test@example.com\",\"campaigns\":\"test_campaign\",\"email_address\":\"test@example.com\",\"first_name\":\"John\",\"master_person_id\":\"12345\"}}]"
        )
        .to_return(status: 200, body: "", headers: {})

      salesforce_worker.perform(form.id, params, [campaign_code], master_person_id)
    end
  end
end
