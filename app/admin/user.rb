# frozen_string_literal: true

ActiveAdmin.register User do
  menu priority: 1
  permit_params :username, :first_name, :last_name, :has_access

  config.filters = false

  index do
    selectable_column
    column :username
    column :first_name
    column :last_name
    column :has_access
    actions
  end

  form do |f|
    f.inputs do
      f.input :username, required: true
      f.input :first_name
      f.input :last_name
      f.input :has_access, as: :boolean
    end
    f.actions
  end
end
