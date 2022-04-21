# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profile, type: :model do
  describe "initialize" do
    it "sets attributes properly" do
      # Prepare
      name = Faker::Name.last_name
      email = Faker::Internet.email
      form = build(:form)
      field_name = create(:field, name: "name", input: "text")
      field_email = create(:email_field)
      create(:form_field, form: form, field: field_name, required: true)
      create(:form_field, form: form, field: field_email)
      params = ActionController::Parameters.new(name: name, email_address: email)

      # Test
      profile = Profile.new(form, params)

      # Verify
      expect(profile.errors).to eq({})
      expect(profile.form).to eq(form)
      expect(profile.params.keys.length).to eq(2)
      expect(profile.params["name"]).to eq(name)
      expect(profile.params["email_address"]).to eq(email)
    end
  end

  describe "valid?" do
    it "returns true for profile without errors" do
      # Prepare
      form = build(:form)
      params = ActionController::Parameters.new({})
      profile = Profile.new(form, params)

      # Test and verify
      expect(profile.valid?).to be_truthy
    end
    it "returns false when there are errors" do
      # Prepare
      form = build(:form)
      params = ActionController::Parameters.new({})
      profile = Profile.new(form, params)
      profile.errors["hello"] = "world"

      # Test and verify
      expect(profile.valid?).to be_falsey
    end
  end

  describe "validate_format" do
    it "validates successfully for proper email" do
      # Stub
      stub_request(:post, "https://#{BriteVerify::API_HOST}/api/v1/fullverify")
        .to_return(status: 200, body: {email: {status: "valid"}}.to_json, headers: {})

      # Prepare
      email = Faker::Internet.email
      form = build(:form)
      field_email = create(:email_field, global_registry_attribute: "email_address.email")
      create(:form_field, form: form, field: field_email)
      params = ActionController::Parameters.new(email_address: email)
      profile = Profile.new(form, params)

      # Test
      profile.send :validate_format

      # Verify
      expect(profile.errors).to eq({})
      expect(profile.valid?).to be_truthy
    end

    it "invalidates for bad formatted email" do
      # Stub
      stub_request(:post, "https://#{BriteVerify::API_HOST}/api/v1/fullverify")
        .to_return(status: 200, body: {email: {status: "invalid"}}.to_json, headers: {})

      # Prepare
      email = "this is not an email"
      form = build(:form)
      field_email = create(:email_field, global_registry_attribute: "email_address.email")
      create(:form_field, form: form, field: field_email)
      params = ActionController::Parameters.new(email_address: email)
      profile = Profile.new(form, params)

      # Test
      profile.send :validate_format

      # Verify
      expect(profile.errors[field_email.name]).to eq("Please enter a valid email address.")
      expect(profile.valid?).to be_falsey
    end
  end
end
