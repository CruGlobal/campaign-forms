//= require jquery
//= require jquery-form
//= require jquery-validation/dist/jquery.validate

// Campaign Form
(function ($) {
    var campaignForm = window.campaignForm = window.campaignForm || {};
    campaignForm.jQuery = $.noConflict(true);

    window.recaptchaCallback = campaignForm.recaptchaCallback = function (token) {
        var form = $('.campaign-form form').get(0);
        campaignForm.submitForm(form)
    };

    var formSubmitted = false;

    campaignForm.submitForm = function (form) {
      if (!formSubmitted) {
        formSubmitted = true;
        $(form).ajaxSubmit({
            method: 'POST',
            dataType: 'json',
            success: function (data, status, xhr) {
                // Submit Adobe Analytics event if present
                if (typeof window._satellite !== 'undefined') {
                    // Extend data layer with master_person_id
                    if (typeof data.master_person_id !== 'undefined')
                        window.digitalData = $.extend(true, {}, window.digitalData || {}, {
                            user: [{profile: [{profileInfo: {grMasterPersonId: data.master_person_id}}]}]
                        });
                    // Extend data layer with campaign_code
                    if (typeof data.campaign_codes !== 'undefined' && data.campaign_codes.length > 0)
                        window.digitalData = $.extend(true, {}, window.digitalData || {}, {
                            page: {pageInfo: {emailList: 'ACS | ' + data.campaign_codes.join(' | ')}}
                        });
                    window._satellite.track('aa-email-signup');
                }

                // Call optional success callback if defined
                if (typeof campaignForm.successCallback === 'function') {
                    campaignForm.successCallback(data.master_person_id)
                }

                // redirect if setup
                if (typeof data.redirect_url !== 'undefined') {
                    window.location.href = data.redirect_url;
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
                if (typeof errors.error !== 'undefined')
                    $('.campaign-form .alert-danger').removeClass('hidden');
                // show errors from rails
                validator.showErrors(errors);
                formSubmitted = false;
            }
        });
      }
    };

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
                if ($('.campaign-form .g-recaptcha').length && typeof grecaptcha !== 'undefined') {
                    grecaptcha.execute();
                } else {
                    campaignForm.submitForm(form)
                }
            }
        });
    });
})(jQuery);
