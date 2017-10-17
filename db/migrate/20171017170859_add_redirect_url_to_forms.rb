class AddRedirectUrlToForms < ActiveRecord::Migration[5.1]
  def change
    add_column :forms, :redirect_url, :string
  end
end
