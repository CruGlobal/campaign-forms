# frozen_string_literal: true

ActiveAdmin.register Form do
  menu priority: 10
  permit_params :campaign_code, :name, :style, :title, :body, :action, :success, :created_by_id,
                form_fields_attributes: %i[id field_id label help required placeholder position _destroy]

  config.filters = false

  index do
    selectable_column
    column :name
    column 'Adobe Campaign', :campaign_code do |f|
      Service.active_admin_collection.key(f.campaign_code) || f.campaign_code
    end
    column :created_by
    actions
  end

  show do |form|
    if form.style == 'inline'
      panel 'Preview' do
        iframe src: form_path(id: form.id), style: 'width: 100%; min-height: 300px;'
      end
      panel 'Embed code' do
        textarea id: 'adobe-campaign-form', style: 'width: 100%; min-height: 600px;' do
          render 'form', form: form, preview: false
        end
      end
    else
      columns do
        column do
          panel 'Preview' do
            iframe src: form_path(id: form.id), style: 'width: 100%; min-height: 600px;'
          end
        end

        column do
          panel 'Embed code' do
            textarea id: 'adobe-campaign-form', style: 'width: 100%; min-height: 600px;' do
              render 'form', form: form, preview: false
            end
          end
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name, required: true, hint: 'Name used internally for form'
      f.input :campaign_code, label: 'Adobe Campaign', required: true, as: :select, include_blank: false,
                              collection: Service.active_admin_collection
      f.input :style, as: :select, collection: %w[basic inline], include_blank: false
      f.input :title, input_html: { maxlength: 2048, rows: 2 }, hint: 'Allows HTML. Optional'
      f.input :body, label: 'Body Text', input_html: { maxlength: 4096, rows: 3 }, hint: 'Allows HTML. Optional'
      f.input :action, label: 'Submit Button', input_html: { value: f.object.action || 'Subscribe' }
      f.input :success, label: 'Success Message',
                        input_html: { maxlength: 4096, rows: 3, value: f.object.success || Form::DEFAULT_SUCCESS },
                        hint: 'Allows HTML. Optional'
      f.input :created_by_id, as: :hidden, input_html: { value: f.object.created_by_id || current_user.id }
    end

    f.has_many :form_fields, allow_destroy: true, sortable: :position do |fields_f|
      fields_f.inputs do
        fields_f.input :field, include_blank: false
        fields_f.input :label, hint: 'Override field label. Leave blank to use default field label.'
        fields_f.input :placeholder, hint: 'Override field placeholder.'
        fields_f.input :help, hint: 'Optional help message.'
        fields_f.input :required, as: :boolean, label: 'Is field required?'
      end
    end

    f.actions
  end
end
