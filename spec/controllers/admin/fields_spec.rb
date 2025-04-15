# frozen_string_literal: true

require "rails_helper"
require "capybara/rails"

RSpec.describe Admin::FormFieldsController, type: :controller do
  render_views

  before(:each) do
    @user = create(:user, has_access: true)
    sign_in @user
  end

  describe "GET index" do
    it "returns users" do
      # Prepare
      field = create(:field_full)
      field2 = create(:field, input: "radio", placeholder: SecureRandom.alphanumeric(10))
      op_value1 = create(:option_value)
      op_value2 = create(:option_value)
      create(:field_option, field: field2, option_value: op_value1)
      create(:field_option, field: field2, option_value: op_value2)
      # Test
      get :index

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to have_content(field.name)
      expect(response.body).to have_content(field.input)
      expect(response.body).to have_content(field.label)
      expect(response.body).to have_content(field.placeholder)
      expect(response.body).to have_content(field.global_registry_attribute)
      expect(response.body).to have_content(field.adobe_campaign_attribute)

      expect(response.body).to have_content(op_value1.name)
      expect(response.body).to have_content(op_value2.name)

      expect(response.body).to have_content(field2.name)
      expect(response.body).to have_content(field2.input)
      expect(response.body).to have_content(field2.label)
      expect(response.body).to have_content(field2.placeholder)
    end
  end

  describe "GET new" do
    it "renders form for new field" do
      # Test
      get :new

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to have_field("Name")
      expect(response.body).to have_field("Input Type")
      expect(response.body).to have_field("Label")
      expect(response.body).to have_field("Placeholder")
      expect(response.body).to have_field("Global registry attribute")
      expect(response.body).to have_field("Campaign Name")
    end
  end

  describe "POST create" do
    it "creates field" do
      # Prepare
      field_attributes = {
        name: Faker::Lorem.word,
        input: "number",
        label: Faker::Lorem.word,
        placeholder: Faker::Lorem.word,
        global_registry_attribute: Faker::Lorem.word,
        adobe_campaign_attribute: Faker::Lorem.word
      }

      # Test and verify
      expect {
        post :create, params: {field: field_attributes}
      }.to change(Field, :count).by(1)

      new_field = Field.last
      expect(new_field).to be
      expect(new_field.name).to eq(field_attributes[:name])
      expect(new_field.input).to eq(field_attributes[:input])
      expect(new_field.label).to eq(field_attributes[:label])
      expect(new_field.placeholder).to eq(field_attributes[:placeholder])
      expect(new_field.global_registry_attribute).to eq(field_attributes[:global_registry_attribute])
      expect(new_field.adobe_campaign_attribute).to eq(field_attributes[:adobe_campaign_attribute])
      expect(response).to redirect_to(admin_form_field_path(new_field))
    end
  end

  describe "GET edit" do
    it "should get field for edit" do
      # Prepare
      field = create(:field_full)

      # Test
      get :edit, params: {id: field.id}

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to have_field("Name", with: field.name)
      expect(response.body).to have_field("Input Type", with: field.input)
      expect(response.body).to have_field("Label", with: field.label)
      expect(response.body).to have_field("Placeholder", with: field.placeholder)
      expect(response.body).to have_field("Global registry attribute", with: field.global_registry_attribute)
      expect(response.body).to have_field("Campaign Name", with: field.adobe_campaign_attribute)
    end
  end

  describe "PUT update" do
    it "updates the field" do
      # Prepare
      field = create(:field_full)
      field_attributes = {
        name: Faker::Lorem.word,
        input: "number",
        label: Faker::Lorem.word,
        placeholder: Faker::Lorem.word,
        global_registry_attribute: Faker::Lorem.word,
        adobe_campaign_attribute: Faker::Lorem.word
      }

      # Test
      put :update, params: {id: field.id, field: field_attributes}

      # Verify
      expect(response).to redirect_to(admin_form_field_path(field))

      updated_field = Field.last
      expect(updated_field).to be
      fields = %i[name input label placeholder global_registry_attribute adobe_campaign_attribute]
      fields.each do |f|
        expect(updated_field.send(f)).to eq(field_attributes[f])
      end
    end
  end

  describe "GET show" do
    it "shows the field" do
      # Prepare
      field = create(:field_full)

      # Test
      get :show, params: {id: field.id}

      # Verify
      expect(response.status).to eq(200)
      fields = %i[name input label placeholder global_registry_attribute adobe_campaign_attribute]
      fields.each do |f|
        expect(response.body).to have_content(field.send(f))
      end
    end
  end

  describe "DELETE destroy" do
    it "deletes field" do
      # Prepare
      field = create(:field_full)

      # Test
      delete :destroy, params: {id: field.id}

      # Verify
      expect(response).to redirect_to(admin_form_fields_path)
      expect {
        Field.find(field.id)
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
