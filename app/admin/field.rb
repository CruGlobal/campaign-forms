# frozen_string_literal: true

ActiveAdmin.register Field, as: 'Form Fields' do
  permit_params :name, :input, :label, :placeholder, :global_registry_attribute, :adobe_campaign_attribute,
                field_options_attributes: %i[id option_value_id position _destroy]

  config.filters = false

  index do
    selectable_column
    column :name
    column 'Input Type', :input
    column :label
    column :placeholder
    column 'Global Registry', :global_registry_attribute
    column 'Adobe Campaign', :adobe_campaign_attribute
    column 'Options' do |field|
      field.option_values.pluck(:name).join(', ') if %w[select radio].include?(field.input)
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name, required: true
      f.input :input, as: :select, label: 'Input Type', required: true, collection: Field::INPUT_TYPES,
                      include_blank: false
      f.input :label
      f.input :placeholder, hint: 'Value displayed when field is empty. Not used with select or radio.'
      f.input :global_registry_attribute, hint: 'Name of attribute on Person entity_type. Use \'.\' for nested ' \
                                                ' fields. Ex: email_address.email'
      f.input :adobe_campaign_attribute, hint: 'Name of field on Adobe Campaign profile.'
    end

    f.has_many :field_options, heading: 'Options (select, radio)', allow_destroy: true,
                               sortable: :position do |options_f|
      options_f.inputs do
        options_f.input :option_value
      end
    end

    f.actions
  end
end
