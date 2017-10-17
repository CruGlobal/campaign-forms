//= require jquery
//= require jquery-form
//= require jquery-validation/dist/jquery.validate

// Campaign Form
(function ($) {
    var campaignForm = window.campaignForm = window.campaignForm || {};
    campaignForm.jQuery = $.noConflict(true);

    $(function () {
        var validator = $('.campaign-form form').validate({
            errorElement: 'span',
            errorClass: 'help-block',
            errorPlacement: function (error, element) {
                error.removeAttr('for').appendTo(element.closest('.form-group'));
            },
            highlight: function (element) {
                $(element).closest('.form-group').addClass('has-error');
            },
            unhighlight: function (element) {
                $(element).closest('.form-group').removeClass('has-error');
            },
            submitHandler: function (form) {
                // Hide general error if present
                $('.campaign-form .alert-danger').addClass('hidden');
                $(form).ajaxSubmit({
                    method: 'POST',
                    dataType: 'json',
                    success: function (data, status, xhr) {
                        // Submit Adobe Analytics event if present
                        if (typeof window._satellite !== 'undefined') {
                            if (typeof data.master_person_id !== 'undefined')
                                window.digitalData = $.extend(true, {}, window.digitalData || {}, {
                                    user: [{profile: [{profileInfo: {grMasterPersonId: data.master_person_id}}]}]
                                });
                            window._satellite.track('aa-email-signup');
                        }

                        // Call optional success callback if defined
                        if (typeof campaignForm.successCallback === 'function') {
                            campaignForm.successCallback(data.master_person_id)
                        }

                        // redirect if setup
                        if (window.campaignRedirectUrl) {
                          window.location.href = window.campaignRedirectUrl
                        } else {
                          // Show Success message
                          $('.campaign-form .alert-success')
                              .removeClass('hidden');

                          // Disable and hide form
                          $('.campaign-form form')
                              .addClass('hidden')
                              .find('input, button')
                              .prop('disabled', 'disabled');
                        }
                    },
                    error: function (xhr) {
                        var errors = xhr.responseJSON || {};
                        // Show general error if error key present
                        if(typeof errors.error !== 'undefined')
                            $('.campaign-form .alert-danger').removeClass('hidden');
                        // show errors from rails
                        validator.showErrors(errors);
                    }
                });
            }
        });
    });
})(jQuery);
