# SETTINGS VIEW
# --------------------------------------------------------------------------
# Represents the Settings overlay.

class System.App.SettingsView extends System.OverlayView

    $localStorageDiv: null        # the local storage contents wrapper
    $localStorageClearBut: null   # the "Clear local storage" button
    $serverErrorsDiv: null        # the server errors contents wrapper
    $serverErrorsClearBut: null   # the "Clear server errors" button
    $modifierDelete: null         # the "Delete" modifier keys div
    $modifierMultiple: null       # the "Multiple" modifier keys div
    $modifierToBack: null         # the "To Back" modifier keys div


    # INIT AND DISPOSE
    # ----------------------------------------------------------------------

    # Init the Settings overlay view.
    initialize: =>
        @overlayInit "#settings"
        @setDom()
        @setEvents()

    # Dispose the Settings overlay view and set the frame source to blank.
    dispose: =>
        @baseDispose()

    # Set the DOM elements cache.
    setDom: =>
        @$menuItem = $ "#menu-settings"

        @$localStorageDiv = $ "#settings-localstorage-contents"
        @$localStorageClearBut = $ "#settings-localstorage-clear-but"
        @$serverErrorsDiv = $ "#settings-servererrors-contents"
        @$serverErrorsClearBut = $ "#settings-servererrors-clear-but"

        @$modifierDelete = $ "#settings-modifierkeys-delete"
        @$modifierMultiple = $ "#settings-modifierkeys-multiple"
        @$modifierToBack = $ "#settings-modifierkeys-toback"

    # Bind events to the DOM.
    setEvents: =>
        @$localStorageClearBut.click @clearLocalStorage
        @$serverErrorsClearBut.click @clearServerErrors

        @$el.find(".modifiers").click @modifierClick


    # LOCAL STORAGE
    # ----------------------------------------------------------------------

    # Bind the local storage contents to the `@$localStorageDiv`.
    bindLocalStorage: =>
        @$localStorageDiv.html JSON.stringify(JSON.parse(localStorage.localData), null, 4)

    # Clear the local storage. Ask the user if he really wants to proceed, first.
    clearLocalStorage: =>
        $.localData.flush()
        @$localStorageDiv.html "CLEARED!"


    # SERVER ERRORS
    # ----------------------------------------------------------------------

    # Bind the server errors array to the `@$serverErrorsDiv`.
    bindServerErrors: =>
        result = ""
        errorList = System.App.Sockets.serverErrors

        _.each errorList, (err) ->
            time = err.timestamp.toTimeString()
            sep = time.indexOf "("
            time = time.substring(0, sep - 1) if sep > 0
            result += "#{err.title} #{err.message} at #{time}<br />"

        @$serverErrorsDiv.html result

    # Clear the server errors list.
    clearServerErrors: =>
        System.App.alertView.serverErrors = []
        @$serverErrorsDiv.html "CLEARED!"


    # MODIFIER KEYS
    # ----------------------------------------------------------------------

    # Bind the current set of modifier keys from local storage. If no
    bindModifierKeys: =>
        @parseModifierKeys @$modifierDelete, System.App.Data.userSettings.modifierDelete()
        @parseModifierKeys @$modifierMultiple, System.App.Data.userSettings.modifierMultiple()
        @parseModifierKeys @$modifierToBack, System.App.Data.userSettings.modifierToBack()

    # Parse a combination of modifier keys and highlight the matched div's elements.
    parseModifierKeys: (div, combination) =>
        keys = combination.replace("  ", " ").split " "
        div.find(".active").removeClass "active"
        div.find(".#{k}").addClass("active") for k in keys

    # When user clicks on a modifier span, highlight it and save to the current
    # [User Settings](userSettings.html).
    modifierClick: (e) =>
        src = $ e.target
        parent = src.parent()
        modifierWrapper = parent.parent()
        modifierName = modifierWrapper.data "modifier"
        modifierValue = ""

        # If span is already selected, set `empty` to true to unselect it.
        if src.hasClass "active"
            empty = true
        else
            empty = false

        parent.children("span").removeClass("active")
        src.addClass "active" if not empty

        # Get active elements and generate the modifier value based on their
        # classe names, excluding the `.active` class and trimmed down.
        activeKeys = modifierWrapper.find ".active"
        modifierValue += " " + $(k).attr "class" for k in activeKeys
        modifierValue = modifierValue.replace /active/g, ""
        modifierValue = modifierValue.replace "  ", " "
        modifierValue = $.trim modifierValue

        console.log "New modifier combination for #{modifierName}", modifierValue

        # Set the new modifier value and save the model ONLY locally.
        System.App.Data.userSettings.set "modifier#{modifierName}", modifierValue


    # SHOW AND HIDE
    # ----------------------------------------------------------------------

    # Bind data after showing the view, and listen to "server:error" events
    # to populate the `$serverErrorsDiv`.
    onShow: =>
        System.App.serverEvents.off "error", @bindServerErrors
        System.App.serverEvents.on "error", @bindServerErrors

        @bindLocalStorage()
        @bindServerErrors()
        @bindModifierKeys()

    # When view gets hidden, stop listening to the "server:error" events.
    onHide: =>
        System.App.serverEvents.off "error", @bindServerErrors