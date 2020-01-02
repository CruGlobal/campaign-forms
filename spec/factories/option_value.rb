# frozen_string_literal: true

FactoryBot.define do
  factory :option_value do
    name { SecureRandom.alphanumeric(30) }
    label { SecureRandom.alphanumeric(30) }
  end
end
