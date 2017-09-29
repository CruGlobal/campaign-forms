# frozen_string_literal: true

class User < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:cas]

  def self.find_or_create_from_auth_hash(auth_hash)
    existing = find_by(sso_guid: auth_hash.extra.ssoGuid)
    return existing.apply_auth_hash(auth_hash) if existing

    pending = find_by(username: auth_hash.extra.user)
    return pending.apply_auth_hash(auth_hash) if pending

    new.apply_auth_hash(auth_hash)
  end

  def apply_auth_hash(auth_hash)
    self.sso_guid = auth_hash.extra.ssoGuid
    self.username = auth_hash.uid
    self.first_name = auth_hash.extra.firstName
    self.last_name = auth_hash.extra.lastName
    save!
    self
  end

  def name
    [first_name, last_name].join(' ')
  end
end
