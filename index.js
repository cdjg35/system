// SERVER APP
// -------------------------------------------------------------------------
// This is a shim file to run the `index.coffee` in case CoffeeScript is not
// globally installed. If you have CoffeeScript installed globally (coffee command)
// please run the `index.coffee` directly.

require("coffee-script");
require("coffee-script/register");
require("./index.coffee");