# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "find_or_create_from_auth_hash" do
    before(:each) do
      @sso_guid = SecureRandom.uuid
      @uid = "#{Faker::Name.first_name}_#{Faker::Name.last_name}"
      @auth_hash = OpenStruct.new
      @auth_hash.uid = @uid
      @auth_hash.extra = OpenStruct.new
      @auth_hash.extra.ssoGuid = @sso_guid
      @auth_hash.extra.firstName = Faker::Name.first_name
      @auth_hash.extra.lastName = Faker::Name.last_name
      @auth_hash.info = OpenStruct.new
      @auth_hash.info.email = Faker::Internet.email
    end

    it "finds the existing user and updates its data" do
      # Prepare
      existing_user = create(:user, sso_guid: @sso_guid)
      create(:user, username: @uid.downcase)

      # Test
      result = User.find_or_create_from_auth_hash(@auth_hash)
      expect(result.id).to eq(existing_user.id)
      expect(result.sso_guid).to eq(@sso_guid)
      expect(result.username).to eq(@uid)
      expect(result.first_name).to eq(@auth_hash.extra.firstName)
      expect(result.last_name).to eq(@auth_hash.extra.lastName)
      expect(result.email).to eq(@auth_hash.info.email)
    end

    it "updates data for pending user" do
      # Prepare
      pending_user = create(:user, username: @uid.downcase)

      # Test
      result = User.find_or_create_from_auth_hash(@auth_hash)
      expect(result.id).to eq(pending_user.id)
      expect(result.sso_guid).to eq(@sso_guid)
      expect(result.username).to eq(@uid)
      expect(result.first_name).to eq(@auth_hash.extra.firstName)
      expect(result.last_name).to eq(@auth_hash.extra.lastName)
      expect(result.email).to eq(@auth_hash.info.email)
    end

    it "creates a new user when there is neither existing nor pending" do
      # Test
      result = User.find_or_create_from_auth_hash(@auth_hash)
      expect(result.sso_guid).to eq(@sso_guid)
      expect(result.username).to eq(@uid)
      expect(result.first_name).to eq(@auth_hash.extra.firstName)
      expect(result.last_name).to eq(@auth_hash.extra.lastName)
      expect(result.email).to eq(@auth_hash.info.email)
    end
  end

  describe "name" do
    it "returns a name as compound of first and last names" do
      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      user = create(:user, first_name: first_name, last_name: last_name)
      expect(user.name).to eq("#{first_name} #{last_name}")
    end
  end
end
