class AddRecaptchaToForm < ActiveRecord::Migration[5.1]
  def change
    add_column :forms, :use_recaptcha, :boolean, default: false
    add_column :forms, :recaptcha_key, :string, default: nil
    add_column :forms, :recaptcha_secret, :string, default: nil
  end
end
