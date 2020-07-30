/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
//= require active_admin/base
//= require activeadmin_addons/all
//= require active_admin_flat_skin

$(document).on('change', '.form_form_fields_select', function() {
  var options = $(this).parents('ol:first').find('.has_many_container.campaign_options');
  if ($(this).find(':selected').attr('data-field-type') === 'campaign') {
    return options.show();
  } else {
    return options.hide();
  }
});

$(document).on('ready page:load', function() {
  $('[data-toggle]').on("change", function() {
    return $($(this).data('toggle')).toggle($(this).prop('checked'));
  });
  return $('[data-field-type="campaign"]:selected').parents('ol:first').find('.has_many_container.campaign_options').show();
});