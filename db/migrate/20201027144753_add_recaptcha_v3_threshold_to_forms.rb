class AddRecaptchaV3ThresholdToForms < ActiveRecord::Migration[6.0]
  def change
    add_column :forms, :recaptcha_v3_threshold, :float, default: 0.5
  end
end
