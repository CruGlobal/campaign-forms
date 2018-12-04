# frozen_string_literal: true

FactoryBot.define do
  factory :option_value do
    name  { Faker::Lorem.word }
    label { Faker::Lorem.word }
  end
end
