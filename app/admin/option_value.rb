# frozen_string_literal: true

ActiveAdmin.register OptionValue, as: 'Options' do
  menu priority: 30
  permit_params :name, :label

  config.filters = false

  index do
    selectable_column
    column :name
    column :label
    actions
  end
end
