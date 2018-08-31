# frozen_string_literal: true

class Field < ApplicationRecord
  INPUT_TYPES = %w[text email number tel url radio select campaign].freeze
  has_many :field_options, dependent: :destroy
  has_many :option_values, through: :field_options, dependent: :nullify

  has_many :form_fields, dependent: :destroy
  has_many :forms, through: :form_fields, dependent: :nullify

  validates :input, inclusion: INPUT_TYPES

  accepts_nested_attributes_for :field_options, allow_destroy: true
end
