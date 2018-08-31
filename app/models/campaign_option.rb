# frozen_string_literal: true

class CampaignOption < ApplicationRecord
  default_scope { order(:position) }
  belongs_to :form_field

  def label_value
    label.presence || Service.active_admin_collection.key(campaign_code)
  end
end
