# frozen_string_literal: true

class FieldOption < ApplicationRecord
  default_scope { order(:position) }
  belongs_to :field
  belongs_to :option_value

  delegate :name, :label, to: :option_value
end
