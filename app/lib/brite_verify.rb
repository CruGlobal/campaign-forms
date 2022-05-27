require "net/http"

module BriteVerify
  API_HOST = "bpi.briteverify.com"
  FULLVERIFY = "https://#{API_HOST}/api/v1/fullverify"

  def self.valid_email?(email_address)
    # Policy: Only return false when BriteVerify says 'invalid'
    # _and_ the secondary error_code is _not_ one of [mailbox_full_invalid role_address] - we like those.
    # In all other cases, including protocol failure, return true.
    Net::HTTP.start(API_HOST, 443, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(URI(FULLVERIFY))
      req["Authorization"] = "ApiKey: #{ENV.fetch("BRITE_VERIFY_API_KEY")}"
      req.content_type = "application/json"
      req.body = {email: email_address}.to_json
      res = http.request(req)
      return true if res.code != "200" # Verify by default if BriteVerify query doesn't work
      res_json = JSON.parse(res.body) # Might error; rescued below to verify by default
      return true if res_json.dig("email", "status") != "invalid" # Empty or non-invalid response
      %w[mailbox_full_invalid role_address].include?(res_json.dig("email", "error_code")) # Only accept these two invalid statuses
    rescue JSON::ParserError
      return true
    end
  end
end
