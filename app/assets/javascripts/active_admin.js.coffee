#= require active_admin/base
#= require active_admin_flat_skin

$(document).on 'ready page:load', ->
  $('[data-toggle]').on "change", ->
    $($(this).data('toggle')).toggle($(this).prop('checked'))