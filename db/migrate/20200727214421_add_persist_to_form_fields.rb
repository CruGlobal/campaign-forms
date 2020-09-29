class AddPersistToFormFields < ActiveRecord::Migration[6.0]
  def change
    add_column :form_fields, :persist, :boolean, default: false
  end
end
