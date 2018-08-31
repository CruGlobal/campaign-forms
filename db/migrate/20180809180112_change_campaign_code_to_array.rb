class ChangeCampaignCodeToArray < ActiveRecord::Migration[5.1]
  def change
    change_column :forms, :campaign_code, :string, array: true, default: '{}', using: "(string_to_array(campaign_code, ','))"
    rename_column :forms, :campaign_code, :campaign_codes
  end
end
