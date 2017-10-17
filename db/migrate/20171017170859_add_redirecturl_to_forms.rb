class UpdateForms < ActiveRecord::Migration[5.1]
  def change
    add_column :forms, :redirecturl, :string
  end
end
