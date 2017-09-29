# frozen_string_literal: true

ActiveAdmin.register OptionValue, as: 'Options' do
  permit_params :name, :label

  config.filters = false
end
