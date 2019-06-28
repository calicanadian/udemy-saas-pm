# function to get params from URL
GetURLParameter = (sParam) ->
  sPageURL = window.location.search.substring(1)
  sURLVariables = sPageURL.split("&")
  i = 0
  while i < sURLVariables.length
    sParameterName = sURLVariables[i].split('=')
    if sParameterName[0] == sParam
      return sParameterName[1]
    i++

$ ->

  # function to handle the submit of the form and intercept the default event
  submitHandler = (event) ->
    $form = $(event.target)
    # $form.find("input[type=submit]").prop("disabled", true)
    if Stripe
      try
        Stripe.card.createToken $form, stripeResponseHandler
      catch err
        # show_error(err)
        console.log err
    else
      show_error("Failed to load credit card processing functionality, please reload the page")
    return false

  # initiate submit handler listener for any form with class cc_form
  $(".cc_form").on "submit", submitHandler(event)

  # handle event of plan drop down changing
  handlePlanChange = (plan_type, form) ->
    $form = $(form)
    if plan_type == undefined
      plan_type = $("#tenant_plan :selected").val()
    if plan_type == "premium"
      $("[data-stripe]").prop('required', true)
      $form.off('submit')
      $form.on('submit', submitHandler)
      $('[data-stripe]').show()
    else
      $('[data-stripe]').hide()
      $form.off('submit')
      $('[data-stripe]').removeProp('required')

  # function to call plan change handler so that the plan is set correctly in the
  # drop down when the page loads
  $("#tenant_plan").on "change", (event) ->
    handlePlanChange($("#tenant_plan :selected").val(), ".cc_form")

  # setup plan change event listener for #tenant_plan id in the forms for class cc_form
  handlePlanChange(GetURLParameter('plan'), ".cc_form")

  # function to handle the token received from Stripe and remove credit card fields
  stripeResponseHandler = (status, response) ->
    $form = $(".cc_form")

    if response.error
      console.log response.error.message
      show_error response.error.message
      $form.find("input[type=submit]").prop("disabled", false)
    else
      token = response.id
      $form.append($("<input type='hidden' name='payment[token]' />").val(token))
      $("[data-stripe=number]").remove()
      $("[data-stripe=cvc]").remove()
      $("[data-stripe=exp-month]").remove()
      $("[data-stripe=exp-year]").remove()
      $("[data-stripe=label]").remove()
      $form.get(0).submit()
    false

  # show errors when Stripe functionality returns an error
  show_error = (message) ->
    if $("#flash-messages").size() < 1
      $(".container.main div:first").prepend("<div id='flash-messages'></div>")
    $("#flash-messages").html("
      <div class='alert alert-warning'>
        <a class='close' data-dismiss='alert'>x</a>
        <div id='flash_alert'>
          " + message + "
        </div>
      </div>
    ")
    $(".alert").delay(5000).fadeOut(3000)
    return false
