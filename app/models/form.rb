# frozen_string_literal: true

class Form < ApplicationRecord
  DEFAULT_SUCCESS = "<div><strong>Congratulations!</strong> You have successfully subscribed.</div>"
  VALID_STYLES = %w[basic inline].freeze

  has_many :form_fields, dependent: :destroy
  has_many :fields, through: :form_fields, dependent: :nullify
  belongs_to :created_by, class_name: "User" # rubocop:disable Rails/InverseOf

  # validates :campaign_codes, presence: true, unless: :campaigns_field_exists?
  validates :name, presence: true
  validate :recaptcha_required_for_v3
  validates_inclusion_of :recaptcha_v3_threshold, in: 0..1, if: proc { |form| form.recaptcha_v3 }
  validates :recaptcha_v3_threshold, presence: true, if: proc { |form| form.recaptcha_v3 }

  accepts_nested_attributes_for :form_fields, allow_destroy: true

  def campaign_codes=(value)
    # ensure array without empty? values
    super(Array.wrap(value).reject(&:empty?))
  end

  def required_params
    form_fields.where(required: true).includes(:field).map(&:name)
  end

  def permitted_params
    form_fields.includes(:field).map do |form_field|
      if form_field.input == "campaign"
        {form_field.name => []}
      else
        form_field.name
      end
    end
  end

  def initialize(attributes = nil)
    super
    return if attributes.present?
    email_field_id = Field.find_by(input: "email", name: "email_address")&.id
    form_fields.build(field_id: email_field_id, required: true) if email_field_id
  end

  def recaptcha_required_for_v3
    if recaptcha_v3 && !use_recaptcha
      errors.add(:recaptcha_v3, "requires recaptcha")
    end
  end
end
