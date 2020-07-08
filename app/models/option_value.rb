# frozen_string_literal: true

class OptionValue < ApplicationRecord
  has_many :field_options, dependent: :destroy
  has_many :fields, through: :field_options, dependent: :nullify

  validates :label, uniqueness: {scope: :name, case_sensitive: false}

  accepts_nested_attributes_for :field_options, allow_destroy: true
end
