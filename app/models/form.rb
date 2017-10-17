# frozen_string_literal: true

class Form < ApplicationRecord
  DEFAULT_SUCCESS = '<div><strong>Congratulations!</strong> You have successfully subscribed.</div>'
  VALID_STYLES = %w[basic inline].freeze

  has_many :form_fields, dependent: :destroy
  has_many :fields, through: :form_fields, dependent: :nullify
  belongs_to :created_by, class_name: 'User'

  validates :campaign_code, presence: true
  validates :name, presence: true

  accepts_nested_attributes_for :form_fields, allow_destroy: true

  def required_params
    form_fields.where(required: true).includes(:field).map(&:name)
  end

  def permitted_params
    form_fields.includes(:field).map(&:name)
  end

  def initialize(attributes = nil)
    super
    return unless attributes.empty?
    email_field_id = Field.find_by(input: 'email', name: 'email_address')&.id
    form_fields.build(field_id: email_field_id, required: true) if email_field_id
  end
end