class AddSalesforceToFields < ActiveRecord::Migration[7.0]
  def change
    add_column :fields, :salesforce_attribute, :string
    Field.reset_column_information

    # the salesforce field names were made exactly matching the names
    Field.update_all("salesforce_attribute = name")
  end
end
