# frozen_string_literal: true

ActiveAdmin.register Form do
  menu priority: 10
  permit_params :name, :style, :title, :body, :redirect_url, :action, :success, :created_by_id,
    :use_recaptcha, :recaptcha_key, :recaptcha_secret, :recaptcha_v3, :recaptcha_v3_threshold, :origin,
    form_fields_attributes: [:id, :field_id, :label, :help, :required, :placeholder, :position, :_destroy,
      campaign_options_attributes: %i[id campaign_code label position _destroy]],
    campaign_codes: []

  includes :created_by
  order_by(:"users.first_name") do |order_clause|
    if order_clause.order == "desc"
      "users.first_name DESC, users.last_name DESC, forms.name DESC"
    else
      "users.first_name ASC, users.last_name ASC, forms.name ASC"
    end
  end

  config.filters = false

  index do
    selectable_column
    column :name
    list_column "Adobe Campaign(s)", :campaign_codes do |f|
      Service.active_admin_collection.invert.values_at(*f.campaign_codes)
    end
    column :created_by, sortable: "users.first_name"
    column "Uses reCAPTCHA", :use_recaptcha
    actions
  end

  show do |form|
    if form.style == "inline"
      panel "Preview" do
        iframe src: form_path(id: form.id), style: "width: 100%; min-height: 300px;"
      end
      panel "Embed code" do
        textarea id: "adobe-campaign-form", style: "width: 100%; min-height: 600px;" do
          render "form", form: form, preview: false
        end
      end
    else
      columns do
        column do
          panel "Preview" do
            iframe src: form_path(id: form.id), style: "width: 100%; min-height: 600px;"
          end
        end

        column do
          panel "Embed code" do
            textarea id: "adobe-campaign-form", style: "width: 100%; min-height: 600px;" do
              render "form", form: form, preview: false
            end
          end
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name, required: true, hint: "Name used internally for form"
      f.input :campaign_codes, label: "Adobe Campaign", as: :select, include_blank: false,
        collection: Service.active_admin_collection, multiple: true,
        input_html: {class: :select2}
      f.input :style, as: :select, collection: %w[basic inline], include_blank: false
      f.input :title, input_html: {maxlength: 2048, rows: 2}, hint: "Allows HTML. Optional"
      f.input :body, label: "Body Text", input_html: {maxlength: 4096, rows: 3}, hint: "Allows HTML. Optional"
      f.input :action, label: "Submit Button", input_html: {value: f.object.action || "Subscribe"}
      f.input :redirect_url, label: "Redirect url", hint: "Upon successful submit, optionally redirect a user. ie. " \
                                                          "http://www.cru.org/success."
      f.input :origin, hint: "Subscription origin. You must create another form if you want different origins on the " \
                             "same campaign."
      f.input :success, label: "Success Message",
        input_html: {maxlength: 4096, rows: 3, value: f.object.success || Form::DEFAULT_SUCCESS},
        hint: "Allows HTML. Optional"
      f.input :use_recaptcha, as: :boolean, label: "Use reCAPTCHA?", input_html: {"data-toggle": "#recaptcha_keys"},
        hint: 'If using recaptcha v2, requires configuring an <a href="https://www.google.com/recaptcha/admin#list" ' \
              ' target="_blank">Invisible ' \
              "reCAPTCHA</a>".html_safe # rubocop:disable Rails/OutputSafety
      f.input :recaptcha_v3, label: "Use new v3 reCAPTCHA"
      f.input :recaptcha_v3_threshold, hint: "1.0 is very likely a good interaction, 0.0 is very likely a bot. Submissions less than this value will be rejected."
      f.inputs name: "reCAPTCHA Keys", id: "recaptcha_keys", style: f.object.use_recaptcha ? "" : "display: none;" do
        f.input :recaptcha_key, label: "reCAPTCHA Site Key"
        f.input :recaptcha_secret, label: "reCAPTCHA Secret Key"
      end
      f.input :created_by_id, as: :hidden, input_html: {value: f.object.created_by_id || current_user.id}
    end

    f.has_many :form_fields, allow_destroy: true, sortable: :position do |fields_f|
      fields_f.inputs do
        fields_f.input :field,
          include_blank: false, input_html: {class: "form_form_fields_select"},
          collection: Field.all.map { |field| [field.name, field.id, "data-field-type": field.input] }
        fields_f.input :label, hint: "Override field label. Leave blank to use default field label."
        fields_f.input :placeholder, hint: "Override field placeholder."
        fields_f.input :help, hint: "Optional help message."
        fields_f.input :required, as: :boolean, label: "Is field required?"
        fields_f.has_many :campaign_options, allow_destroy: true, sortable: :position,
          heading: "Campaigns" do |campaigns_f|
          campaigns_f.inputs do
            campaigns_f.input :campaign_code, label: "Campaign", as: :select, include_blank: false,
              collection: Service.active_admin_collection,
              input_html: {class: :select2}
            campaigns_f.input :label, hint: "Override Campaign name. Leave blank to use default name."
          end
        end
      end
    end

    f.actions
  end
end
