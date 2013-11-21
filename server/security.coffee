# SERVER SECURITY
# --------------------------------------------------------------------------
# This security module will handle all security and authentication related
# procedures of the app. The `init` method is called when the app starts.

class Security

    # Require Expresser.
    expresser = require "expresser"
    settings = expresser.settings

    # Required modules.
    crypto = require "crypto"
    database = require "./database.coffee"
    moment = require "moment"

    # Passport is accessible from outside.
    passport: require "passport"

    # Cache with logged users to avoid hitting the database all the time.
    # The default expirty time is 1 minute.
    cachedUsers: null

    # The default guest user.
    guestUser: {id: "guest", displayName: "Guest", username: "guest", roles: ["guest"]}

    # Init all security related stuff. Set the passport strategy to
    # authenticate users using basic HTTP authentication.
    init: =>
        @cachedUsers = {}

        # Only add passowrd protection if enabled on settings.
        return if not @getPassportStrategy()?

        # User serializer will user the user ID only.
        @passport.serializeUser (user, callback) => callback null, user.id

        # User deserializer will get user details from the database.
        @passport.deserializeUser (user, callback) =>
            if user is "guest"
                @validateUser "guest", null, callback
            else
                @validateUser {id: user}, false, callback

        # Enable LDAP authentication?
        if settings.passport.ldap.enabled
            ldapAuth = require "ldapauth"
            ldapStrategy = (require "passport-ldapauth").Strategy
            ldapOptions =
                server:
                    url: settings.passport.ldap.server
                    adminDn: settings.passport.ldap.adminDn
                    adminPassword: settings.passport.ldap.adminPassword
                    searchBase: settings.passport.ldap.searchBase
                    searchFilter: settings.passport.ldap.searchFilter

            strategy = new ldapStrategy ldapOptions, (profile, callback) => @validateUser profile, callback
            @passport.use strategy
            expresser.app.server.use @passport.session()
            expresser.logger.debug "Security", "Passport: using LDAP authentication."

        # Enable basic HTTP authentication?
        else if settings.passport.basic.enabled
            httpStrategy = (require "passport-http").BasicStrategy
            strategy = new httpStrategy (username, password, callback) => @validateUser username, password, callback
            @passport.use strategy
            expresser.app.server.use @passport.session()
            expresser.logger.debug "Security", "Passport: using basic HTTP authentication."

        # Make sure we have the admin user created.
        @ensureAdminUser()

    # Helper to validate user login. If no user was specified and [settings](settings.html)
    # allow guest access, then log as guest.
    validateUser: (user, password, callback) =>
        expresser.logger.debug "Security", "validateUser", user, password.replace(/./gi, "*")

        if not user? or user is "" or user is "guest" or user.id is "guest"
            if settings.security.guestEnabled
                return callback null, @guestUser
            else
                return callback null, false, {message: "Username was not specified."}

        # Check if user should be fetched by ID or username.
        if not user.id?
            filter = {username: user}
        else
            fromCache = @cachedUsers[user.id]
            filter = user

        # Add password hash to filter.
        if password isnt false
            filter.passwordHash = @getPasswordHash user, password

        # Check if user was previously cached. If not valid, delete from cache.
        if fromCache?.cacheExpiryDate?
            if fromCache.cacheExpiryDate.isAfter(moment())
                return callback null, fromCache
            delete @cachedUsers[user.id]

        # Get user from database.
        database.getUser filter, (err, result) =>
            if err?
                return callback err
            else if not result? or result.length < 1
                return callback null, false, {message: "User and password combination not found."}

            result = result[0] if result.length > 0

            # Set expiry date for the user cache.
            result.cacheExpiryDate = moment().add "s", settings.security.userCacheExpires
            @cachedUsers[result.id] = result

            # Return the login callback.
            return callback null, result

    # Ensure that there's at least one admin user registered. The default
    # admin user will have username "admin", password "system".
    ensureAdminUser: =>
        database.getUser null, (err, result) =>
            if err?
                expresser.logger.error "Security.ensureAdminUser", err
                return

            # If no users were found, create the default admin user.
            if not result? or result.length < 1
                passwordHash = @getPasswordHash "admin", "system"
                user = {displayName: "Administrator", username: "admin", roles:["admin"], passwordHash: passwordHash}
                database.setUser user
                expresser.logger.info "Security.ensureAdminUser", "Default admin user was created."


    # AUTHENTICATION METHODS
    # ----------------------------------------------------------------------

    # Generates a password hash based on the provided `username` and `password`,
    # along with the `Settings.User.passwordSecretKey`. This is mainly used
    # by the HTTP authentication module. If password is empty, return an empty string.
    getPasswordHash: (username, password) =>
        return "" if not password? or password is ""
        text = username + "|" + password + "|" + settings.security.userPasswordKey
        return crypto.createHash("sha256").update(text).digest "hex"


    # HELPER METHODS
    # ----------------------------------------------------------------------

    # Returns the current passport strategy by checking the `settings.passport` properties.
    getPassportStrategy: =>
        if settings.passport.ldap.enabled
            return "ldapauth"
        else if settings.passport.basic.enabled
            return "basic"
        return null



# Singleton implementation
# --------------------------------------------------------------------------
Security.getInstance = ->
    @instance = new Security() if not @instance?
    return @instance

module.exports = exports = Security.getInstance()