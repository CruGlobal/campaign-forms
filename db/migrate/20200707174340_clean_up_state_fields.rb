class CleanUpStateFields < ActiveRecord::Migration[6.0]
  ITEMS_TO_SKIP = %w[AA AE AP AS GU MP PR UM VI]

  def up
    state = Field.find_by(name: "State",
      input: "select",
      label: "State",
      global_registry_attribute: "address.state",
      adobe_campaign_attribute: "location.stateCode",
      placeholder: nil)

    FieldOption.where(field: state, option_value_id: nil).delete_all

    option = OptionValue.find_or_create_by(name: "AA", label: "Select a State")
    FieldOption.find_or_create_by(field: state, option_value: option, position: 0)

    states = ISO3166::Country.find_country_by_alpha3("USA").states.sort_by { |state| state[1].name }
    states.each_with_index do |item, index|
      next if ITEMS_TO_SKIP.include?(item[0])
      option_value = OptionValue.find_or_create_by(name: item[0], label: item[1].name)
      FieldOption.find_or_create_by(field: state, option_value: option_value, position: index + 1)
    end
  end

  def down
    states = ISO3166::Country.find_country_by_alpha3("USA").states
    states.each do |item|
      next if ITEMS_TO_SKIP.include?(item[0])
      OptionValue.find_by(name: item[0], label: item[1].name)&.destroy
    end

    OptionValue.find_by(name: "AA", label: "Select a State")&.destroy

    Field.find_by(name: "State")&.destroy
  end
end
