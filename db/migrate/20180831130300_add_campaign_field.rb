class AddCampaignField < ActiveRecord::Migration[5.1]
  def up
    # Create 'campaigns' field
    Field.find_or_create_by(name: "campaigns",
      input: "campaign",
      label: "Select one or more lists to subscribe to:",
      global_registry_attribute: nil,
      adobe_campaign_attribute: nil,
      placeholder: nil)
  end

  def down
    Field.destroy(input: "campaign")
  end
end
