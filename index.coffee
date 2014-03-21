# SERVER APP
# --------------------------------------------------------------------------

# Expresser.
expresser = require "expresser"

# Required modules.
lodash = expresser.libs.lodash
manager = require "./server/manager.coffee"
path = require "path"
security = require "./server/security.coffee"
sockets = require "./server/sockets.coffee"
flash = require "connect-flash"
# Init Expresser.
initOptions = {app: [flash(), security.passport.initialize(), security.passport.session()]}
expresser.init initOptions

# Init other modules.
security.init()
manager.init()
sockets.init()

# Add app routes.
require("./server/routes.coffee")(expresser.app.server)