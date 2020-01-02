# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :user do
    username { Faker::Internet.unique.username }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    has_access { true }
  end
end
