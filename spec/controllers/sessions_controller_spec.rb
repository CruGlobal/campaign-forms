# frozen_string_literal: true

require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  before do
    @sso_guid = SecureRandom.uuid
    @uid = "#{Faker::Name.first_name}_#{Faker::Name.last_name}"
    @auth_hash = OpenStruct.new
    @auth_hash.uid = @uid
    @auth_hash.extra = OpenStruct.new
    @auth_hash.extra.raw_info = OpenStruct.new
    @auth_hash.extra.raw_info.ssoguid = @sso_guid
    @auth_hash.info = OpenStruct.new
    @auth_hash.info.first_name = Faker::Name.first_name
    @auth_hash.info.last_name = Faker::Name.last_name
    @auth_hash.info.email = Faker::Internet.email
    OmniAuth.config.test_mode = true
    request.env["omniauth.auth"] = @auth_hash
  end

  describe "#create" do
    it "should successfully login an existing user" do
      # Prepare
      user = create(:user, sso_guid: @sso_guid, has_access: true)
      request.env["devise.mapping"] = Devise.mappings[:user]

      # Test
      post :oktaoauth

      # Verify
      expect(controller.current_user.id).to eq(user.id)
    end

    it "should successfully create a user" do
      # Prepare
      request.env["devise.mapping"] = Devise.mappings[:user]

      # Test
      post :oktaoauth

      # Verify
      # expect(controller.current_user.id).to eq(user.id)

      expect(controller.current_user).to be
      expect(controller.current_user.has_access).to eq(false)
    end
  end
end
