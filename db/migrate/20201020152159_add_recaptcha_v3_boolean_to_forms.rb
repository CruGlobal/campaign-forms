class AddRecaptchaV3BooleanToForms < ActiveRecord::Migration[6.0]
  def change
    add_column :forms, :recaptcha_v3, :boolean, default: true
    Form.reset_column_information
    # default all current existing forms to not use recaptcha_v3
    Form.update_all(recaptcha_v3: false)
  end
end
