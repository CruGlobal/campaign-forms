
# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :form, class: 'Form' do
    name { Faker::Name.name }
    association :created_by, factory: :user

    factory :empty_form do
      initialize_with { new({}) }
    end
  end
end
