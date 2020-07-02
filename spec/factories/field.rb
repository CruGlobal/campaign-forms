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

    factory :birthday_day_field do
      input { "number" }
      name { "birthdate_day" }
      label { "Birthday Day of Month" }
    end

    factory :birthday_month_field do
      input { "number" }
      name { "birthdate_month" }
      label { "Birthday Month" }
    end

    factory :birthday_year_field do
      input { "number" }
      name { "birthdate_year" }
      label { "Birthday Year" }
    end
  end
end
