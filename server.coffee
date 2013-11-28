# SERVER APP
# --------------------------------------------------------------------------

# Expresser.
expresser = require "expresser"

# Required modules.
lodash = require "lodash"
manager = require "./server/manager.coffee"
path = require "path"
security = require "./server/security.coffee"
sockets = require "./server/sockets.coffee"
flash = require "connect-flash"

# Set init options.
initOptions = {app: [flash(), security.passport.initialize(), security.passport.session()]}

# Init modules.
expresser.init initOptions
security.init()
manager.init()
sockets.init()

# Configure the app and set the routes.
require("./server/routes.coffee")(expresser.app.server)