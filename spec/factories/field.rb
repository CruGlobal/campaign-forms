# frozen_string_literal: true

FactoryBot.define do
  factory :field do
    input { "text" }
    name { "name" }
    label { "Name" }

    factory :field_full do
      placeholder { SecureRandom.alphanumeric(10) }
      global_registry_attribute { SecureRandom.alphanumeric(10) }
      adobe_campaign_attribute { SecureRandom.alphanumeric(10) }
    end

    factory :email_field do
      input { "email" }
      name { "email_address" }
      label { "Email address" }
    end

    factory :state_field do
      input { "text" }
      name { "State" }
      label { "State" }
    end
  end
end
