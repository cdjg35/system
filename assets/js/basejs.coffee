# System App - Base JS
# -----------------------------------------------------------------------------
# This holds all common libraries and dependencies.

#= require app.instance.coffee

# LIBS
# -----------------------------------------------------------------------------
#= require lib/jquery.js
#= require lib/jquery.localdata.js
#= require lib/jquery.cookie.js
#= require lib/jquery.joyride.js
#= require lib/jquery.tinycolourpicker.js
#= require lib/jsonpath.js
#= require lib/lodash.js
#= require lib/backbone.js
#= require lib/async.js
#= require lib/raphael.js
#= require lib/raphael.link.js
#= require lib/raphael.group.js
#= require lib/moment.js

# MODULES
# -----------------------------------------------------------------------------
#= require settings.coffee
#= require messages.coffee
#= require vectors.coffee
#= require dataUtil.coffee
#= require routes/appRoutes.coffee

# BASE MODELS AND VIEWS
# -----------------------------------------------------------------------------
#= require model/base.coffee
#= require view/baseView.coffee

# COMMON VARIABLES, ROUTES AND DOM CACHE
# -----------------------------------------------------------------------------
SystemApp.startDate = new Date()
SystemApp.routes = null
SystemApp.$loading = null
SystemApp.$debug = null