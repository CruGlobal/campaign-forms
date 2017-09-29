class DeviseCreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.uuid :sso_guid, null: false
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :email
      t.boolean :has_access, default: false
      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
