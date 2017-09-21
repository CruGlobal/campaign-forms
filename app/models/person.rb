# frozen_string_literal: true

class Person
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  extend AutoStripAttributes

  PERSON_ATTRIBUTES = %i[first_name last_name email_address].freeze

  attr_accessor(*PERSON_ATTRIBUTES)

  auto_strip_attributes(*PERSON_ATTRIBUTES)

  validates :email_address, presence: true,
                            email_format: true

  # Overriding @record[key]=val, that's only found in activerecord, not in ActiveModel
  def []=(key, val)
    instance_variable_set(:"@#{key}", val)
  end

  def [](key)
    k = :"@#{key}"
    instance_variable_defined?(k) ? instance_variable_get(k) : nil
  end

  def person_attrs
    attrs = {}
    PERSON_ATTRIBUTES.each { |name| attrs[name.to_s] = send(name) }
    attrs.compact
  end
end
