# frozen_string_literal: true

class Profile
  attr_accessor :form, :params, :errors

  def initialize(form, params)
    self.errors = {}
    self.form = form
    self.params = parse params
  end

  def valid?
    errors.empty?
  end

  private

  def parse(params)
    # Strip Whitespace and remove nils on all permitted params first
    permitted = params.permit(form.permitted_params).to_h.transform_values do |value|
      StripAttributes.strip_string value, collapse_spaces: true, replace_newlines: true
    end.compact

    # Test for required params
    form.required_params.each do |param|
      errors[param] = 'This field is required.' unless permitted.key? param
    end

    permitted
  end
end
