
# frozen_string_literal: true

FactoryBot.define do
  factory :campaign_option do
    form_field
    campaign_code { SecureRandom.uuid }
    label { Faker::Lorem.word }
  end
end
