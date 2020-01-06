# frozen_string_literal: true

class MasterPersonId
  attr_accessor :form, :params

  def initialize(form, params)
    self.form = form
    self.params = params
  end

  # - match on email
  # -- if one match, use it
  # -- if 0 or many - create record
  def find_or_create_id
    return unless email_address
    entities = find_entities_by_email
    entities = Array.wrap(create_entity) unless entities.size == 1
    relationships = entities.first&.dig("person", "master_person:relationship")
    # wrap relationships, there was a bug where some people have more than 1 master_person, take the first
    Array.wrap(relationships)&.dig(0, "master_person") if relationships
  end

  private

  def find_entities_by_email
    params = {entity_type: :person, fields: "master_person:relationship",
              'filters[email_address][email]': email_address,
              'filters[owned_by]': "all", per_page: 1,}
    Array.wrap(GlobalRegistry::Entity.get(params)&.dig("entities"))
  rescue RestClient::BadRequest
    []
  end

  def create_entity
    GlobalRegistry::Entity.post({entity: {person: person_entity}},
      params: {full_response: "true",
               fields: "master_person:relationship",
               require_mdm: "true",})&.dig("entity")
  end

  def person_entity
    entity = {}
    params.each do |key, value|
      field = form.fields.find_by(name: key)
      next if field.global_registry_attribute.blank?
      entity.deep_merge!(hasherize(field.global_registry_attribute.split("."), value))
    end
    entity
  end

  def email_address_name
    return @email_address_name if @email_field_set
    @email_field_set = true
    @email_address_name = form.fields.find_by(input: "email", global_registry_attribute: "email_address.email")&.name
  end

  def email_address
    @email_address ||= params[email_address_name]
  end

  # Recursively converts 'foo.bar.baz' = value to { foo: { bar: { baz: value } } } and adding client_integration_id
  def hasherize(keys = [], value = nil)
    if keys.empty?
      value
    else
      {:client_integration_id => email_address, keys.shift => hasherize(keys, value)}
    end
  end
end
