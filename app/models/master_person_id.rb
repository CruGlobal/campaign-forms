# frozen_string_literal: true

class MasterPersonId
  attr_accessor :person

  def initialize(person)
    self.person = person
  end

  # - match on email
  # -- if one match, use it
  # -- if 0 or many - create record
  # - In the background, update with other attributes (first/last)
  # -- Update will automatically trigger fuzzy matching and do a merge if appropriate.
  def find_or_create_id
    entities = find_entities
    entities = Array.wrap(create_entity) unless entities.size == 1
    entities.first&.dig('person', 'master_person:relationship', 'master_person')
  end

  private

  def find_entities
    params = { entity_type: :person, fields: 'master_person:relationship',
               'filters[email_address][email]': person.email_address,
               'filters[owned_by': 'all', per_page: 1 }
    Array.wrap(GlobalRegistry::Entity.get(params)&.dig('entities'))
  rescue RestClient::BadRequest
    []
  end

  def create_entity
    GlobalRegistry::Entity.post({ entity: { person: person_entity } },
                                params: { full_response: 'true',
                                          fields: 'master_person:relationship',
                                          require_mdm: 'true' })&.dig('entity')
  end

  def person_entity
    { email_address: { email: person.email_address, client_integration_id: person.email_address },
      client_integration_id: person.email_address,
      first_name: person.first_name, last_name: person.last_name }.compact
  end
end
