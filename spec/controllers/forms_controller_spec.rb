# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FormsController, type: :controller do
  describe 'GET show/:id' do
    render_views

    it 'renders form - no fields, no recaptcha' do
      # Prepare
      body = SecureRandom.uuid
      title = SecureRandom.uuid
      form = create(:form, body: body, title: title)

      # Test
      get :show, params: { id: form.id }

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to match(/<div class="container">/im)
      expect(response.body).to match(%r{<div>#{body}<\/div>}im)
      expect(response.body).not_to match(/class="g-recaptcha"/im)
    end

    it 'renders "record Not Found"' do
      # Prepare
      id = SecureRandom.rand(1_000_000)

      # Test
      get :show, params: { id: id }

      # Verify
      expect(response.status).to eq(404)
      expect(response.body).to eq({ error: "Couldn't find Form with 'id'=#{id}" }.to_json)
    end

    it 'renders form - no fields, recaptcha' do
      # Prepare
      body = SecureRandom.uuid
      title = SecureRandom.uuid
      form = create(:form, body: body, title: title, use_recaptcha: true)

      # Test
      get :show, params: { id: form.id }

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to match(/<div class="container">/im)
      expect(response.body).to match(%r{<div>#{body}<\/div>}im)
      expect(response.body).to match(/class="g-recaptcha"/im)
    end

    it 'renders form - with fields, recaptcha' do
      # Prepare
      body = SecureRandom.uuid
      title = SecureRandom.uuid
      form = create(:form, body: body, title: title, use_recaptcha: true)
      field = create(:field, name: 'name_1', input: 'text')
      create(:form_field, form: form, field: field, required: true)

      # Test
      get :show, params: { id: form.id }

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to match(/<div class="container">/im)
      expect(response.body).to match(%r{<div>#{body}<\/div>}im)
      expect(response.body).to match(/class="g-recaptcha"/im)
      expect(response.body).to match(/<input id="cf_name_1_(\d+)" class="form-control" type="text" name="name_1"/im)
    end
  end

  describe 'create' do
    before(:each) do
      @body = SecureRandom.uuid
      @title = SecureRandom.uuid
      @form = create(:form, body: @body, title: @title)
      @field_email = create(:email_field, global_registry_attribute: 'email_address.email')
      @form_field = create(:form_field, form: @form, field: @field_email)
    end

    it 'returns "Bad Request"' do
      # Test
      post :create, params: { id: @form.id, email_address: 'not an email' }

      # Verify
      expect(response.status).to eq(400)
      expect(response.body).to eq({ email_address: 'Please enter a valid email address.' }.to_json)
    end

    it 'returns error for missing reCAPTCHA' do
      # Prepare
      @form.use_recaptcha = true
      @form.save!

      # Test
      post :create, params: { id: @form.id, email_address: Faker::Internet.email }

      # Verify
      expect(response.status).to eq(401)
      expect(response.body).to eq({ error: 'Unauthorized' }.to_json)
    end

    it 'returns OK - without campaign codes' do
      # Prepare
      email = Faker::Internet.email
      master_person_id = SecureRandom.rand(1_000_000)
      expect_any_instance_of(MasterPersonId).to receive(:find_or_create_id).and_return(master_person_id)

      # Test
      post :create, params: { id: @form.id, email_address: email }

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to eq({ master_person_id: master_person_id, campaign_codes: [] }.to_json)
    end

    it 'returns OK - with campaign codes' do
      # Prepare
      email = Faker::Internet.email
      master_person_id = SecureRandom.rand(1_000_000)
      expect_any_instance_of(MasterPersonId).to receive(:find_or_create_id).and_return(master_person_id)
      # Campaign field
      campaign_field = create(:field, input: 'campaign', name: 'c_name')
      create(:form_field, form: @form, field: campaign_field)
      expect(AdobeCampaignWorker).to receive(:perform_async).once
      c_name = SecureRandom.uuid

      # Test
      post :create, params: { id: @form.id, email_address: email, c_name: [c_name] }

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to eq({ master_person_id: master_person_id, campaign_codes: [c_name] }.to_json)
    end
  end
end
