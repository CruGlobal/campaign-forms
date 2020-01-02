# frozen_string_literal: true

class Profile
  attr_accessor :form, :params, :errors, :permitted

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
    self.permitted = params.permit(form.permitted_params).to_h.transform_values do |value|
      StripAttributes.strip_string value, collapse_spaces: true, replace_newlines: true
    end.compact

    validate_required
    validate_format

    permitted
  end

  def validate_required
    # Test for required params
    form.required_params.each do |param|
      errors[param] = "This field is required." unless permitted.key? param
    end
  end

  def validate_format
    if email_address # rubocop:disable Style/GuardClause
      # Use same RegExp as Global Registry to catch invalid emails before sending there.
      unless email_address.match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
        errors[email_address_name] = "Please enter a valid email address."
      end
    end
  end

  def email_address_name
    @email_address_name ||= form.fields.find_by(input: "email", global_registry_attribute: "email_address.email")&.name
  end

  def email_address
    @email_address ||= permitted[email_address_name]
  end
end
