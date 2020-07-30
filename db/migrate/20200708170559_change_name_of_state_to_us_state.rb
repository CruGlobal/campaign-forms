class ChangeNameOfStateToUsState < ActiveRecord::Migration[6.0]
  def up
    state = Field.find_by(name: "State",
                          input: "select",
                          label: "State",
                          global_registry_attribute: "address.state",
                          adobe_campaign_attribute: "location.stateCode")
    state&.update(name: "US_State")
  end

  def down
    state = Field.find_by(name: "US_State",
                          input: "select",
                          label: "State",
                          global_registry_attribute: "address.state",
                          adobe_campaign_attribute: "location.stateCode")
    state&.update(name: "State")
  end
end
