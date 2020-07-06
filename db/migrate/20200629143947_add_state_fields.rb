class AddStateFields < ActiveRecord::Migration[5.2]
  def up
    state = Field.find_or_create_by(name: "State",
                                    input: "select",
                                    label: "State",
                                    global_registry_attribute: "address.state",
                                    adobe_campaign_attribute: "location.stateCode",
                                    placeholder: nil)

    state.option_values.clear
    state.field_options.clear

    items_to_skip = %w[AA AE AP AS UM VI]

    option = OptionValue.find_or_create_by(name: "AA", label: "Select a state")
    FieldOption.find_or_create_by(field: state, option_value: option, position: 0)

    states = ISO3166::Country.find_country_by_alpha3("USA").states.sort_by { |state| state[1].name }
    states.each_with_index do |item, index|
      next if items_to_skip.include?(item[0])
      option_value = OptionValue.find_or_create_by(name: item[0], label: item[1].name)
      FieldOption.find_or_create_by(field: state, option_value: option_value, position: index + 1)
    end
  end

  def down
    Field.find_by(name: "State").delete_all

    items_to_skip = %w[AA AE AP AS UM VI]

    OptionValue.find_by(name: "Choose a state", label: "AA").delete_all

    states = ISO3166::Country.find_country_by_alpha3("USA").states
    states.each do |item|
      next if items_to_skip.include?(item[0])
      OptionValue.find_by(name: item[0], label: item[1].name).delete_all
    end
  end
end
