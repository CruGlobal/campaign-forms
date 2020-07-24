# frozen_string_literal: true

class FormField < ApplicationRecord
  default_scope { order(:position) }
  belongs_to :form
  belongs_to :field
  has_many :campaign_options, dependent: :destroy

  delegate :name, :input, :field_options, to: :field

  accepts_nested_attributes_for :campaign_options, allow_destroy: true

  def label_value
    label.presence || field.label.presence || name
  end

  def placeholder_value
    placeholder.presence || field.placeholder.presence || label_value
  end

  def partial
    return "date" if name.starts_with?('birthdate_')
    return input if %(select radio campaign).include?(input)
    "input"
  end
end
