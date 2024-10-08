const postScriptLoad = function () {
  // Only initialize campaign-forms JS if it hasn't loaded previously.
  if (typeof window.campaignForms === 'undefined') {

    // Campaign Forms
    (function ($) {
      var campaignForms = window.campaignForms = window.campaignForms || {}
      var campaignForm = window.campaignForm = window.campaignForm || {}
      var idCounter = 0

      campaignForms.jQuery = $.noConflict(true)

      function uniqueFormId () {
        var id = ++idCounter
        return 'campaignForm' + id
      }

      function submitForm (form, recaptchaToken) {
        var formId = form.attr('id')

        if (!campaignForms[formId].formSubmitted) {
          campaignForms[formId].formSubmitted = true

          const data = campaignForms[formId].v3
            ? { "g-recaptcha-response": recaptchaToken }
            : {};

          form.ajaxSubmit({
            method: 'POST',
            dataType: 'json',
            data: data,
            success: function (data, status, xhr) {
              // Submit Adobe Analytics event if present
              if (typeof window._satellite !== 'undefined') {
                // Extend data layer with master_person_id
                if (typeof data.master_person_id !== 'undefined')
                  window.digitalData = $.extend(true, {}, window.digitalData || {}, {
                    user: [{profile: [{profileInfo: {grMasterPersonId: data.master_person_id}}]}]
                  })
                // Extend data layer with campaign_code
                if (typeof data.campaign_codes !== 'undefined' && data.campaign_codes.length > 0)
                  window.digitalData = $.extend(true, {}, window.digitalData || {}, {
                    page: {pageInfo: {emailList: 'ACS | ' + data.campaign_codes.join(' | ')}}
                  })
                window._satellite.track('aa-email-signup')
              }

              window.dataLayer = window.dataLayer || []
              window.dataLayer.push({
                'event': 'ga-email-signup'
              })

              // Call optional success callback if defined
              if (typeof campaignForm.successCallback === 'function') {
                window.campaignForm.successCallback(data.master_person_id)
              }
              form[0].dispatchEvent(new CustomEvent('cf:form-submitted', {
                detail: { fields: form.formToArray() }
              }))

              // redirect if setup
              if (typeof data.redirect_url !== 'undefined') {
                window.location.href = data.redirect_url
              } else {
                // Show Success message
                form.parents('.campaign-form').find('.alert-success').removeClass('hidden')

                // Disable and hide form
                form.addClass('hidden').find('input, button').prop('disabled', 'disabled')
              }
            },
            error: function (xhr) {
              var errors = xhr.responseJSON || {}
              // Show general error if error key present
              if (typeof errors.error !== 'undefined')
                form.parents('.campaign-form').find('.alert-danger').removeClass('hidden')
              // show errors from rails
              campaignForms[formId].formSubmitted = false
              campaignForms[formId].validator.showErrors(errors)
            }
          })
        }
      }

      function validate (form) {
        return form.validate({
          errorElement: 'span',
          errorClass: 'help-block',
          errorPlacement: function (error, element) {
            error.removeAttr('for').appendTo(element.closest('.form-group'))
          },
          highlight: function (element) {
            $(element).closest('.form-group').addClass('has-error')
          },
          unhighlight: function (element) {
            $(element).closest('.form-group').removeClass('has-error')
          },
          submitHandler: function (form) {
            // Hide general error if present
            const $form = $(form);
            $form
              .parents(".campaign-form")
              .find(".alert-danger")
              .addClass("hidden");

            const formId = $form.attr('id')

            const recaptchaSiteKey = $form.attr("data-recaptcha-sitekey");

            if (campaignForms[formId].v3 && recaptchaSiteKey && typeof grecaptcha !== "undefined") {
              grecaptcha.ready(() =>
                grecaptcha
                  .execute(recaptchaSiteKey, { action: "submit" })
                  .then((recaptchaToken) => submitForm($form, recaptchaToken))
              );
            } else if (!campaignForms[formId].v3 && $form.find('.g-recaptcha').length && typeof grecaptcha !== 'undefined') {
              var recaptchaDiv = $form.find('.g-recaptcha')[0]
              var recaptchaId
              Object.keys(___grecaptcha_cfg.clients).forEach(function (key) {
                var item = ___grecaptcha_cfg.clients[key]
                Object.keys(item).forEach(function (prop) {
                  if (recaptchaDiv === item[prop])
                    recaptchaId = item.id
                })
              })

              window.recaptchaCallback = function() { submitForm($form) }

              if (typeof recaptchaId !== 'undefined') {
                grecaptcha.execute(recaptchaId)
              } else {
                grecaptcha.execute()
              }
            } else {
              submitForm($form)
            }
          }
        })
      }

      // Register all existing forms (not previously registered)
      window.campaignForms.registerForms = function () {
        $('.campaign-form form:not([id])').each(function () {
          var form = $(this)

          // Check id again, just to be safe
          if (typeof form.attr('id') === 'undefined') {
            var formId = uniqueFormId()
            form.attr('id', formId)
            campaignForms[formId] = {
              validator: validate(form),
              formSubmitted: false
            }

            campaignForms[formId].v3 = form[0].hasAttribute("data-recaptcha-sitekey");

            if (!campaignForms[formId].v3) {
              const recaptchaDiv = $('div[data-sitekey]', form)[0];
              if (recaptchaDiv) {
                $(recaptchaDiv).removeAttr('id')
              }
            }
          }
        })
      }

      // Bootstrap campaign-forms
      window.campaignForms.jQuery(function () {
        window.campaignForms.registerForms()
      })

      $(document).ready(function() {
        $("[id^='cf_Country_']").change(function(){
          if ($(this).val()!='US'){
            $("[for^='cf_US_State_']").hide()
            $("[id^='cf_US_State_']").hide()
          } else {
            $("[for^='cf_US_State_']").show()
            $("[id^='cf_US_State_']").show()
          }
        })
      })

      document.dispatchEvent(new CustomEvent('cf:loaded', {
        detail: { campaignForms }
      }))

      toggleSubmitButtons(false);
    })(jQuery)
  }
};

const toggleSubmitButtons = (disabled) => {
  const forms = document.querySelectorAll('.campaign-form');

  if (forms.length) {
      forms.forEach((form) => {
          const button = form.querySelector('button[type="submit"]');
          button.disabled = disabled;
          if (disabled) {
            button.classList.add('disabled');
          } else {
            button.classList.remove('disabled');
          }

      })
  }
};

const createScriptTag = (info) => {
  return new Promise(function(resolve, reject) {
    let scriptElement = document.createElement('script');
    scriptElement.src = info;
    scriptElement.async = false;
    scriptElement.onload = () => {
      resolve(info);
    };
    scriptElement.onerror = () => {
      reject(info);
    };
    document.body.appendChild(scriptElement);
  });
};

toggleSubmitButtons(true);

const scripts = ['https://ajax.googleapis.com/ajax/libs/jquery/3.7.0/jquery.min.js',
                 'https://cdnjs.cloudflare.com/ajax/libs/jquery.form/4.2.2/jquery.form.min.js',
                 'https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.5/jquery.validate.min.js'];

const loadJqueryScripts = () => {
  let promiseData = [];
  scripts.forEach((info) => {
    promiseData.push(createScriptTag(info));
  });

  Promise.all(promiseData).then(() => {
    postScriptLoad();
  }).catch((data) => {
    console.warn(data + ' failed to load!');
  });
}

if (document.readyState === "loading") {
  // Loading hasn't finished yet
  document.addEventListener("DOMContentLoaded", loadJqueryScripts);
} else {
  // `DOMContentLoaded` has already fired
  loadJqueryScripts();
}
