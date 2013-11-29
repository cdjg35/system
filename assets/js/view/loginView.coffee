# LOGIN VIEW
# --------------------------------------------------------------------------
# Represents the login view.

class SystemApp.LoginView extends SystemApp.BaseView

    $form: null         # the login form
    $txtUser: null      # the "Username" text field
    $txtPassword: null  # the "Password" text field
    $forgot: null       # the "Forgot credentials" link.
    $errorDiv: null     # the div to show errors


    # INIT AND DISPOSE
    # ----------------------------------------------------------------------

    # Init the login view.
    initialize: =>
        @setDom()
        @setEvents()

    # Dispose the menu view.
    dispose: =>
        @baseDispose()

    # Set all DOM elements.
    setDom: =>
        @setElement $ "#login"
        @$form = @$el.find "form"
        @$txtUser = $ "#username"
        @$txtPassword = $ "#password"
        @$forgot = $ "#forgot"
        @$errorDiv = @$el.find "div.error"

    # Bind events to DOM.
    setEvents: =>
        @$form.submit @formValidate
        @$forgot.click "click:createmap", @forgotClick


    # LOGIN METHODS
    # ----------------------------------------------------------------------

    # Validate the login form on submit. Check username and password fields.
    formValidate: (e) =>
        if @$txtUser.val().length < 1
            @$errorDiv.html SystemApp.Messages.errInvalidUsername
            e.preventDefault()
            return false

        if @$txtPassword.val().length < 1
            @$errorDiv.html SystemApp.Messages.errInvalidPassword
            e.preventDefault()
            return false

        # Clear error messages.
        @$errorDiv.html()

    # Show helper when user clicks the "forgot credentials" link.
    forgotClick: (e) =>
        url = SystemApp.Settings.login.forgotCredentialsUrl
        if url? and url isnt ""
            document.location.href = url
        else
            alert SystemApp.Messages.contactAdmin

# STARTING
# -----------------------------------------------------------------------------
$(document).ready ->
    SystemApp.loginView = new SystemApp.LoginView()