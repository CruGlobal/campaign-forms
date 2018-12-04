
# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :form, class: 'Form' do
    name { Faker::Lorem.word }
    association :created_by, factory: :user
    title { SecureRandom.alphanumeric(10) }
    body  { SecureRandom.alphanumeric(20) }

    factory :empty_form do
      initialize_with { new({}) }
    end
  end
end
