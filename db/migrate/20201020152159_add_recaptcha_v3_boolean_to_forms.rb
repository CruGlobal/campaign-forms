class AddRecaptchaV3BooleanToForms < ActiveRecord::Migration[6.0]
  def change
    add_column :forms, :recaptcha_v3, :boolean, default: false
  end
end
