class AddOriginToForm < ActiveRecord::Migration[5.1]
  def change
    add_column :forms, :origin, :string, default: nil
  end
end
