# frozen_string_literal: true

FactoryBot.define do
  factory :field do
    input { 'text' }
    name  { 'name' }
    label { 'Name' }

    factory :email_field do
      input { 'email' }
      name  { 'email_address' }
      label { 'Email address' }
    end
  end
end
