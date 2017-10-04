class RemoveNullConstraint < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :sso_guid, :uuid, null: true, default: nil
  end
end
