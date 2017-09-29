class CreateFormFields < ActiveRecord::Migration[5.1]
  def change
    create_table :fields do |t|
      t.string :name, null: false
      t.string :input, null: false
      t.string :label, null: false
      t.string :global_registry_attribute
      t.string :adobe_campaign_attribute

      t.timestamps
    end

    create_table :option_values do |t|
      t.string :name
      t.string :label

      t.timestamps
    end

    create_table :field_options do |t|
      t.belongs_to :field, index: true
      t.belongs_to :option_value, index: true
      t.integer :position, default: 0

      t.timestamps
    end
  end
end