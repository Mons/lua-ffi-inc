require("ffi-inc")
local ffi = require("ffi")
ffi.constants({"sys/socket.h"},{ "AF_INET","AF_INET6" })
ffi.constants({"errno.h"},{ "EAGAIN" })

print("AF_INET",ffi.const.AF_INET)
print("AF_INET6",ffi.const.AF_INET6)
print("EAGAIN",ffi.const.EAGAIN)

return 2
