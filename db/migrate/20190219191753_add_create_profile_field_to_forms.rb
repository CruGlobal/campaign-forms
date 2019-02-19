class AddCreateProfileFieldToForms < ActiveRecord::Migration[5.1]
  def change
    add_column :forms, :create_profile, :boolean
  end
end
