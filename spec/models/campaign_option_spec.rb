# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CampaignOption, type: :model do
  describe 'label_value' do
    it 'returns label if it exists' do
      # Prepare
      label = Faker::Lorem.word
      co = build(:campaign_option, label: label)

      # Test and verify
      expect(co.label_value).to eq(label)
    end

    it 'returns key from Service.active_admin_collection' do
      # Prepare
      campaign_code = 'abc'
      expect(Service).to receive(:active_admin_collection).and_return(the_key: campaign_code)
      co = build(:campaign_option, label: nil, campaign_code: campaign_code)

      # Test and verify
      expect(co.label_value).to eq(:the_key)
    end
  end
end
