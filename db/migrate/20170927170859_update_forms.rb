class UpdateForms < ActiveRecord::Migration[5.1]
  def change
    add_column :fields, :placeholder, :string, null: true
    add_column :form_fields, :placeholder, :string, null: true
    add_column :forms, :style, :string, null: false, default: "basic"
  end
end
