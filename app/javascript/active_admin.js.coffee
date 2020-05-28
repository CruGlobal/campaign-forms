#= require active_admin/base
#= require activeadmin_addons/all
#= require active_admin_flat_skin

$(document).on 'change', '.form_form_fields_select', ->
  options = $(this).parents('ol:first').find('.has_many_container.campaign_options')
  if $(this).find(':selected').attr('data-field-type') == 'campaign'
    options.show()
  else
    options.hide()

$(document).on 'ready page:load', ->
  $('[data-toggle]').on "change", ->
    $($(this).data('toggle')).toggle($(this).prop('checked'))
  $('[data-field-type="campaign"]:selected').parents('ol:first').find('.has_many_container.campaign_options').show()