class DefaultFields < ActiveRecord::Migration[5.1]
  def up
    # Create first_name, last_name, email_address and gender fields
    Field.find_or_create_by(name: 'email_address',
                            input: 'email',
                            label: 'Email Address',
                            global_registry_attribute: 'email_address.email',
                            adobe_campaign_attribute: 'email',
                            placeholder: nil)
    Field.find_or_create_by(name: 'first_name',
                            input: 'text',
                            label: 'First Name',
                            global_registry_attribute: 'first_name',
                            adobe_campaign_attribute: 'firstName',
                            placeholder: nil)
    Field.find_or_create_by(name: 'last_name',
                            input: 'text',
                            label: 'Last Name',
                            global_registry_attribute: 'last_name',
                            adobe_campaign_attribute: 'lastName',
                            placeholder: nil)
    gender = Field.find_or_create_by(name: 'gender',
                                     input: 'radio',
                                     label: 'Gender',
                                     global_registry_attribute: 'gender',
                                     adobe_campaign_attribute: 'gender',
                                     placeholder: nil)
    gender.option_values.clear
    gender.field_options.clear

    # Create gender option values
    m = OptionValue.find_or_create_by(name: 'Male', label: 'Male')
    f = OptionValue.find_or_create_by(name: 'Female', label: 'Female')
    FieldOption.find_or_create_by(field: gender, option_value: m, position: 0)
    FieldOption.find_or_create_by(field: gender, option_value: f, position: 1)
  end

  def down
    OptionValue.delete_all
    Field.delete_all
    Form.delete_all
  end
end
