# frozen_string_literal: true

require "rails_helper"

RSpec.describe Recaptcha, type: :model do
  describe "initialize" do
    it "sets initial parameters" do
      # Prepare
      form = build(:form)
      recaptcha_response = SecureRandom.alphanumeric(10)
      params = ActionController::Parameters.new("g-recaptcha-response".to_sym => recaptcha_response)
      remote_ip = Faker::Internet.ip_v4_address
      r = Recaptcha.new(form, params, remote_ip)

      # Test and verify
      expect(r.form).to eq(form)
      expect(r.remote_ip).to eq(remote_ip)
      expect(r.recaptcha_response).to eq(recaptcha_response)
    end
  end

  describe "valid?" do
    it "verifies if form does not use recaptcha" do
      # Prepare
      form = build(:form, use_recaptcha: false)
      params = ActionController::Parameters.new({})
      remote_ip = Faker::Internet.ip_v4_address
      r = Recaptcha.new(form, params, remote_ip)

      # Test and verify
      expect(r.valid?).to be_truthy
    end

    it "invalidates if form uses recaptcha and there is no recaptcha_response" do
      # Prepare
      form = build(:form, use_recaptcha: true)
      params = ActionController::Parameters.new({})
      remote_ip = Faker::Internet.ip_v4_address
      r = Recaptcha.new(form, params, remote_ip)

      # Test and verify
      expect(r.valid?).to be_falsey
    end

    context "call to captcha" do
      before(:each) do
        @remote_ip = Faker::Internet.ip_v4_address
        @recaptcha_response = SecureRandom.alphanumeric(10)
        @recaptcha_secret = SecureRandom.alphanumeric(20)
        @form = create(:form, use_recaptcha: true, recaptcha_secret: @recaptcha_secret)
        @body = {remoteip: @remote_ip, response: @recaptcha_response, secret: @recaptcha_secret}

        @stub_request = stub_request(:post, "https://www.google.com/recaptcha/api/siteverify")
          .with(body: @body)

        @params = ActionController::Parameters.new("g-recaptcha-response".to_sym => @recaptcha_response)
      end

      it "validates if request to reCAPTCHA returns success" do
        # Prepare
        @stub_request.to_return(status: 200, body: '{"success": true}', headers: {})

        recaptcha = Recaptcha.new(@form, @params, @remote_ip)

        # Test and verify
        expect(recaptcha.valid?).to be_truthy
      end

      it "Invalidates if request to reCAPTCHA returns failure" do
        # Prepare
        @stub_request.to_return(status: 200, body: '{"success": false}', headers: {})

        recaptcha = Recaptcha.new(@form, @params, @remote_ip)

        # Test and verify
        expect(recaptcha.valid?).to be_falsey
      end

      it "Invalidates if reCAPTCHA returns error, also calls Rollbar" do
        # Prepare
        @stub_request.to_return(status: 200, body: '{"error-codes": 12}', headers: {})

        recaptcha = Recaptcha.new(@form, @params, @remote_ip)

        expect(Rollbar).to receive(:error) do |param1, param2|
          expect(param1).to eq("reCAPTCHA error")
          expect(param2).to eq("error-codes" => 12, :form => @form.id)
        end
        # Test and verify
        expect(recaptcha.valid?).to be_falsey
      end
    end
  end
end
