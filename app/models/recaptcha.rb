# frozen_string_literal: true

class Recaptcha
  attr_accessor :form, :recaptcha_response, :remote_ip

  RECAPTCHA_PARAM = "g-recaptcha-response".to_sym
  RECAPTCHA_VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify"

  def initialize(form, params, remote_ip)
    self.form = form
    self.remote_ip = remote_ip
    self.recaptcha_response = parse_response params
  end

  def valid?
    # always valid if form doesn't use recaptcha
    return true unless form.use_recaptcha

    # recaptcha is enabled, but no response, automatically invalid
    return false unless recaptcha_response
    verify_response
  end

  private

  def parse_response(params)
    permitted = params.permit(RECAPTCHA_PARAM)
    permitted[RECAPTCHA_PARAM]
  end

  def verify_response
    # https://developers.google.com/recaptcha/docs/verify
    response = RestClient.post(RECAPTCHA_VERIFY_URL,
      secret: form.recaptcha_secret,
      response: recaptcha_response,
      remoteip: remote_ip)
    json = JSON.parse(response.body)
    if json["success"]
      return form.recaptcha_v3 ? json["score"] > form.recaptcha_v3_threshold : true
    end
    Rollbar.error("reCAPTCHA error", json.merge(form: form.id)) if json.key? "error-codes"
    false
  end
end
