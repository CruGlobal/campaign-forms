require "net/http"

module BriteVerify
  API_HOST = "bpi.briteverify.com"
  FULLVERIFY = "https://#{API_HOST}/api/v1/fullverify"

  def self.valid_email?(email_address)
    Net::HTTP.start(API_HOST, 443, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(URI(FULLVERIFY))
      req["Authorization"] = "ApiKey: #{ENV.fetch("BRITE_VERIFY_API_KEY")}"
      req.content_type = "application/json"
      req.body = {email: email_address}.to_json
      res = http.request(req)
      return true if res.code != "200" # Verify by default if BriteVerify query doesn't work
      JSON.parse(res.body).dig("email", "status") != "invalid" # Only an "invalid" response will fail
    rescue JSON::ParserError
      return true
    end
  end
end
