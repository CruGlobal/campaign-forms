# frozen_string_literal: true

require "rails_helper"

RSpec.describe MasterPersonId, type: :model do
  describe "initialize" do
    it "sets parameters correctly" do
      # Prepare
      form = build(:form)
      params = ActionController::Parameters.new({})

      # Test
      mpi = MasterPersonId.new(form, params)

      # Verify
      expect(mpi.form).to eq(form)
      expect(mpi.params).to eq(params)
    end
  end

  describe "find_or_create_id" do
    it "returns nothing if there is no email address" do
      # Prepare
      form = build(:form)
      params = ActionController::Parameters.new({})
      mpi = MasterPersonId.new(form, params)

      # Test and verify
      expect(mpi.find_or_create_id).to eq(nil)
    end

    it "calls global registry for entity" do
      # Prepare
      id = SecureRandom.rand(1_000_000)
      email_address = Faker::Internet.email
      body = {
        entities: {
          person: {
            "master_person:relationship": [
              {master_person: {id: id}}
            ]
          }
        }
      }
      stub_request(:get, "https://backend.global-registry.org/entities")
        .with(query: {
          entity_type: "person",
          fields: "master_person:relationship",
          "filters[email_address][email]": email_address,
          "filters[owned_by]": "all",
          per_page: 1
        })
        .to_return(body: body.to_json)

      form = build(:form)
      params = ActionController::Parameters.new(email_address: email_address)
      mpi = MasterPersonId.new(form, params)
      # pretend there is a email field
      expect(mpi).to receive(:email_address_name).and_return("email_address")

      # Test
      result = mpi.find_or_create_id

      # Verify
      expect(result["id"]).to eq(id)
    end
  end

  describe "find_entities_by_email" do
    before(:each) do
      @id = SecureRandom.rand(1_000_000)
      @email_address = Faker::Internet.email
      @stub_request = stub_request(:get, "https://backend.global-registry.org/entities")
        .with(query: {
          entity_type: "person",
          fields: "master_person:relationship",
          "filters[email_address][email]": @email_address,
          "filters[owned_by]": "all",
          per_page: 1
        })
      form = build(:form)
      params = ActionController::Parameters.new(email_address: @email_address)
      @mpi = MasterPersonId.new(form, params)
      expect(@mpi).to receive(:email_address_name).and_return("email_address")
    end

    it "calls global registry" do
      # Prepare
      person = {person: {
        "master_person:relationship": [
          {master_person: {id: @id}}
        ]
      }}
      body = {entities: person}
      @stub_request.to_return(body: body.to_json)

      # Test
      result = @mpi.send :find_entities_by_email

      # Verify
      expect(result.to_json).to eq([person].to_json)
    end
    it "returns nothing if Global Registry returns error" do
      # Prepare
      @stub_request.to_return(status: 400, body: "")

      # Test
      result = @mpi.send :find_entities_by_email

      # Verify
      expect(result).to eq([])
    end
  end

  describe "create_entity" do
    it "returns stubed data" do
      # Prepare
      form = build(:form)
      params = ActionController::Parameters.new({})
      mpi = MasterPersonId.new(form, params)
      person_entity = {id: SecureRandom.rand(1_000_000)}
      expect(mpi).to receive(:person_entity).and_return(person_entity)

      stub_request(:post, "https://backend.global-registry.org/entities")
        .with(
          query: {
            fields: "master_person:relationship",
            full_response: true,
            require_mdm: true
          },
          body: {entity: {person: person_entity}}.to_json
        )
        .to_return(body: {entity: "something"}.to_json)

      # Test
      result = mpi.send :create_entity

      # Verify
      expect(result).to eq("something")
    end
  end

  describe "person_entity" do
    it "prepares entity" do
      # Prepare
      name = Faker::Name.last_name
      email = Faker::Internet.email
      form = build(:form)
      field_name = create(:field, name: "name", input: "text")
      field_email = create(:email_field, global_registry_attribute: "email_address.email")
      create(:form_field, form: form, field: field_name, required: true)
      create(:form_field, form: form, field: field_email)
      params = ActionController::Parameters.new(name: name, email_address: email)
      mpi = MasterPersonId.new(form, params)

      # Test
      result = mpi.send :person_entity

      # Verify
      # noinspection RubyStringKeysInHashInspection
      expected_value = {
        :client_integration_id => email,
        "email_address" => {
          :client_integration_id => email,
          "email" => email
        }
      }
      expect(result).to eq(expected_value)
    end
  end
end
