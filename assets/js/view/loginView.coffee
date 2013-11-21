# LOGIN VIEW
# --------------------------------------------------------------------------
# Represents the login view.

class SystemApp.LoginView extends SystemApp.BaseView

    $forgot: null               # the "Forgot credentials" link.


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
        @$forgot = $ "#forgot"

    # Bind events to DOM.
    setEvents: =>
        @$forgot.click "click:createmap", @forgotClick


    # LOGIN METHODS
    # ----------------------------------------------------------------------

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