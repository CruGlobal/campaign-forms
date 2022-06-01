require "net/http"

module BriteVerify
  API_HOST = "bpi.briteverify.com"
  FULLVERIFY = "https://#{API_HOST}/api/v1/fullverify"

  def self.valid_email?(email_address)
    # Policy: Only return false when BriteVerify says 'invalid'
    # _and_ the secondary reason is _not_ one of: (mailbox_full_invalid, role_address) - we like those.
    # In all other cases, including protocol failure, return true.
    Net::HTTP.start(API_HOST, 443, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(URI(FULLVERIFY))
      req["Authorization"] = "ApiKey: #{ENV.fetch("BRITE_VERIFY_API_KEY")}"
      req.content_type = "application/json"
      req.body = {email: email_address}.to_json
      res = http.request(req)
      return true if res.code != "200" # Validate by default if BriteVerify query doesn't work
      res_json = JSON.parse(res.body) # Might error; rescued below to validate by default
      return true if res_json.dig("email", "status") != "invalid" # Empty or non-invalid response
      return true if res_json.dig("email", "role_address") == true # Invalid due to role_address; we validate these
      return res_json.dig("email", "error_code") == "mailbox_full_invalid" # Also validate these; otherwise, invalid
    rescue JSON::ParserError
      return true
    end
  end
end
