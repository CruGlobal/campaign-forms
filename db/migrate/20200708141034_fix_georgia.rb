class FixGeorgia < ActiveRecord::Migration[6.0]
  def up
    state = Field.find_by(name: "State",
      input: "select",
      label: "State",
      global_registry_attribute: "address.state",
      adobe_campaign_attribute: "location.stateCode",
      placeholder: nil)

    FieldOption.where(field: state, option_value_id: nil).delete_all

    option_value = OptionValue.find_or_create_by(name: "GA", label: "Georgia")
    FieldOption.find_or_create_by(field: state, option_value: option_value, position: 15)
  end

  def down
    OptionValue.find_by(name: "GA", label: "Georgia")&.destroy
  end
end
