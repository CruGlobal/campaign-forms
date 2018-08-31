class CreateCampaignOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :campaign_options do |t|
      t.belongs_to :form_field, null: false, index: true
      t.string :campaign_code
      t.string :label
      t.integer :position, default: 0
      t.timestamps
    end
  end
end
