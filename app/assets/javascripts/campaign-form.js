// Campaign Form
(function ($) {
    var campaignForm = window.campaignForm = window.campaignForm || {};
    campaignForm.jQuery = $.noConflict(true);

    campaignForm.subscribe = function (event) {
        $('.campaign-form form .alert-danger').addClass('hidden');
        $.post({
            url: '/forms',
            dataType: 'json',
            data: $(event.target).serialize()
        }).done(function (data) {
            if (typeof campaignForm.successCallback === 'function') {
                campaignForm.successCallback(data.master_person_id)
            }
            if (typeof campaignForm.successMessage !== 'undefined') {
                $('.campaign-form .alert-success')
                    .removeClass('hidden')
                    .append($(campaignForm.successMessage));
            }
            $('.campaign-form form').addClass('hidden').find('input, button').attr('disabled', 'disabled');
        }).fail(function (response) {
            var div = $('.campaign-form form .alert-danger');
            div.empty();
            $.each(response.responseJSON, function (key, val) {
                $.each(val, function (index, message) {
                    div.append($('<div></div>').text(message));
                });
            });
            div.removeClass('hidden');
        });

        event.preventDefault();
    };

    $(function () {
        $('.campaign-form form').submit(campaignForm.subscribe);
    });
})(jQuery);
