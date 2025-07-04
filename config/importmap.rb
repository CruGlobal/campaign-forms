# Pin npm packages by running ./bin/importmap

# The entrypoint
pin "application", preload: true

# ActiveAdmin and dependencies
pin "@activeadmin/activeadmin", to: "https://cdn.jsdelivr.net/npm/@activeadmin/activeadmin@2.13.1/app/assets/javascripts/active_admin/base.min.js"
pin "jquery", to: "https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.js"
pin "jquery-ui", to: "https://cdn.jsdelivr.net/npm/jquery-ui@1.13.2/dist/jquery-ui.min.js"
pin "jquery-ujs", to: "https://cdn.jsdelivr.net/npm/jquery-ujs@1.2.3/src/rails.min.js"
pin "jquery-validation", to: "https://cdn.jsdelivr.net/npm/jquery-validation@1.21.0/dist/jquery.validate.js"
pin "jquery-form", to: "https://cdn.jsdelivr.net/npm/jquery-form@4.3.0/dist/jquery.form.min.js"

pin "active_admin_custom", to: "custom/active_admin_custom.js"
