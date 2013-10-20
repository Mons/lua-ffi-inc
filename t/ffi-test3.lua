require("ffi-inc")
local ffi = require("ffi")
ffi.include("ares.h",{ "/usr/include/c-ares19" })
ffi.include("ev.h",{ "/usr/include/libev" })

return 2
