# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :form, class: "Form" do
    name { Faker::Lorem.word }
    association :created_by, factory: :user
    title { SecureRandom.alphanumeric(10) }
    body { SecureRandom.alphanumeric(20) }
    create_profile { false }

    factory :empty_form do
      initialize_with { new({}) }
    end

    factory :full_form do
      style { "basic" }
      title { Faker::Lorem.words(4).join(" ") }
      body { Faker::Lorem.paragraph }
      action { "Subscribe" }
      redirect_url { Faker::Internet.url }
      origin { SecureRandom.alphanumeric(6) }
      success { Faker::Lorem.sentence }
    end
  end
end
