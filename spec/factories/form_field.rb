# frozen_string_literal: true

require "securerandom"

FactoryBot.define do
  factory :form_field do
    form
    field
    label { Faker::Lorem.word }
  end
end
