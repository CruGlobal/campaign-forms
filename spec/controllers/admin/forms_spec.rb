# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rails'

RSpec.describe Admin::FormsController, type: :controller do
  render_views

  before(:each) do
    WebMock::RequestRegistry.instance.reset!

    @user = create(:user, has_access: true)
    sign_in @user

    @access_token = SecureRandom.alphanumeric(30)
    @stub = stub_request(:post, 'https://ims-na1.adobelogin.com/ims/exchange/jwt')
            .with(body: { client_id: 'asdf', client_secret: 'asdf', jwt_token: 'asdf' })
            .to_return(status: 200, body: { access_token: @access_token }.to_json)

    # noinspection RubyStringKeysInHashInspection
    all_services = [
      { 'label' => 'label1', 'name' => 'name1' },
      { 'label' => 'label2', 'name' => 'name2' },
      { 'label' => 'label3', 'name' => 'name3' }
    ]
    allow(Service).to receive(:all).and_return(all_services)
  end

  describe 'GET index' do
    it 'returns forms' do
      # Prepare
      form = create(:form, campaign_codes: %w[name1 name3])

      # Test
      get :index

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to have_content(form.name)
      expect(response.body).to have_content('Adobe Campaign(s)')
      expect(response.body).to have_content('label1')
      expect(response.body).not_to have_content('label2')
      expect(response.body).to have_content('label3')
      expect(response.body).to have_content(form.created_by.name)
      expect(response.body).to have_content('Uses reCAPTCHA')
    end
  end

  describe 'GET new' do
    it 'renders new form' do
      # Test
      get :new

      # Verify
      expect(response.status).to eq(200)
      expect(response.body).to have_field('Name')
      expect(response.body).to have_field('Adobe Campaign')
      expect(response.body).to have_field('Style')
      expect(response.body).to have_field('Title')
      expect(response.body).to have_field('Body Text')
      expect(response.body).to have_field('Submit Button')
      expect(response.body).to have_field('Redirect url')
      expect(response.body).to have_field('Origin')
      expect(response.body).to have_field('Success Message')
      # puts response.body
    end
  end

  describe 'POST create' do
    it 'creates form' do
      # Prepare
      form_attributes = {
        name: Faker::Lorem.word,
        campaign_codes: ['name1'],
        style: 'basic',
        title: Faker::Lorem.words(4).join(' '),
        body:  Faker::Lorem.paragraph,
        action:  'Subscribe',
        redirect_url: Faker::Internet.url,
        origin: SecureRandom.alphanumeric(6),
        success: Faker::Lorem.sentence,
        use_recaptcha: true,
        recaptcha_key: SecureRandom.alphanumeric(10),
        recaptcha_secret: SecureRandom.alphanumeric(10),
        created_by_id: @user.id
      }

      # Test and verify
      expect do
        post :create, params: { form: form_attributes }
      end.to change(Form, :count).by(1)

      new_form = Form.last
      expect(new_form).to be
      fields = %i[
        name campaign_codes style title body action redirect_url
        origin success use_recaptcha recaptcha_key recaptcha_secret
        created_by_id
      ]
      fields.each do |f|
        expect(new_form.send(f)).to eq(form_attributes[f])
      end
    end
  end
end
