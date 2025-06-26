# frozen_string_literal: true

class SalesforceService
  AUTH_BASE_URI = ENV.fetch("SALESFORCE_AUTH_URI", "https://mc7f0gw0kcf-9q3hyl7q1yj3jrh4.auth.marketingcloudapis.com")
  REST_BASE_URI = ENV.fetch("SALESFORCE_REST_URI", "https://mc7f0gw0kcf-9q3hyl7q1yj3jrh4.rest.marketingcloudapis.com")

  def self.get_access_token
    Rails.cache.fetch("salesforce_access_token", expires_in: 20.minutes) do
      auth_url = "#{AUTH_BASE_URI}/v2/token"
      payload = {
        "grant_type" => "client_credentials",
        "client_id" => ENV.fetch("SALESFORCE_CLIENT_ID"),
        "client_secret" => ENV.fetch("SALESFORCE_CLIENT_SECRET")
      }

      response = RestClient.post(auth_url, payload.to_json, {content_type: :json, accept: :json})
      JSON.parse(response.body)["access_token"]
    end
  rescue RestClient::Exception => e
    Rails.logger.error("Failed to get Salesforce access token: #{e.message}")
    nil
  end

  def self.send_campaign_subscription(email, campaign_name, data = {})
    Rails.logger.info("SalesforceService#send_campaign_subscription enter, email: #{email}, campaign_name: #{campaign_name}, data: #{data.inspect}")

    access_token = get_access_token
    return false unless access_token

    url = "#{REST_BASE_URI}/hub/v1/dataevents/key:#{ENV.fetch("SFMC_DE_EXTERNAL_KEY")}/rowset"

    #     payload = [
    #       {
    #         keys: {
    #           subscriberkey: email,
    #           campaigns: campaign_name
    #         },
    #         values: {
    #           subscriberkey: email,
    #           campaigns: campaign_name,
    #           email_address: email,
    #
    #           "Alternate_Address": "123 Secondary St, Apartment 4B, Orlando, FL 32801",
    #           "Birth_Date": "1985-03-15",
    #           "Cell_Phone": "+1-407-555-0123",
    #           "City": "Orlando",
    #           "Coach": "Sarah Johnson",
    #           "Country": "United States",
    #           "Country - Latin America": "",
    #           "FamilyLife Campaign Code": "FL2025Q2",
    #           "First_Name": "John",
    #           "Graduation_Date": "2007-05-20",
    #           "Language": "English",
    #           "Last_Name": "Smith",
    #           "Notes": "Interested in leadership programs and community outreach opportunities",
    #           "Salutation": "Mr.",
    #           "Self_Placement": "Graduate Student",
    #           "State_text": "FL",
    #           "TimeZone": "America/New_York",
    #           "US_State": "Florida",
    #           "Whatsapp": "+1-407-555-0123",
    #           "Zip_Code": 32801,
    #           "birthdate_day": 15,
    #           "birthdate_month": 3,
    #           "birthdate_year": 1985,
    #           #"campaigns": "homepage_test_2025",
    #           #"email_address": "john.smith@example.com",
    #           "gender": "Male",
    #           #"subscriberkey": "john.smith@example.com",
    #           "campus": "UCF",
    #           "zip": "32801"
    #
    #         }.merge(data)
    #       }
    #     ].to_json
    #     puts payload
    #
    #     puts(payload.first[:values].keys.join("\n"))

    payload = [
      {
        keys: {
          subscriberkey: email,
          campaigns: campaign_name
        },
        values: {
          subscriberkey: email,
          campaigns: campaign_name,
          email_address: email
        }.merge(data)
      }
    ]

    headers = {
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }

    Rails.logger.info("SalesforceService#send_campaign_subscription url: #{url.inspect}\n\n")
    puts("payload: #{payload.to_json}\n\n")
    puts("headers: #{headers.inspect}\n\n")

    # response = RestClient.post(url, payload.to_json, headers)
    response = RestClient.post(url, payload.to_json, headers)
    response.code == 200
  rescue RestClient::Exception => e
    Rails.logger.error("Failed to send campaign data to Salesforce: #{e.message}")
    false
  end
end
