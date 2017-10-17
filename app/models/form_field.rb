# frozen_string_literal: true

class FormField < ApplicationRecord
  default_scope { order(:position) }
  belongs_to :form
  belongs_to :field

  delegate :name, :input, :field_options, to: :field

  def label_value
    if label.present?
      label
    elsif field.label.present?
      field.label
    else
      name
    end
  end

  def placeholder_value
    placeholder || field.placeholder || label_value
  end

  def partial
    case input
    when 'select', 'radio'
      input
    else
      'input'
    end
  end
end