class AddStateFields < ActiveRecord::Migration[5.2]
  def up
    state = Field.find_or_create_by(name: 'state',
                                    input: 'select',
                                    label: 'State',
                                    global_registry_attribute: 'address.state',
                                    adobe_campaign_attribute: 'location.stateCode',
                                    placeholder: nil)

    state.option_values.clear
    state.field_options.clear
    
    states = ISO3166::Country.find_country_by_alpha3('USA').states.sort_by{ |state| state[1].name}
    states.each_with_index  do |item, index|
      next if item[0] == ("AA" || "AE" || "AP" || "AS" || "UM" || "VI")
      option_value = OptionValue.find_or_create_by(name: item[0], label: item[1].name)
      FieldOption.find_or_create_by(field: state, option_value: option_value, position: index)
    end
  end

  def down
    Field.find_by(name: 'State').delete_all

    states = ISO3166::Country.find_country_by_alpha3('USA').states
    states.each do |item|
      next if item[0] == ("AA" || "AE" || "AP" || "AS" || "UM" || "VI")
      OptionValue.find_by(name: item[0], label: item[1].name).delete_all
    end
  end
end
