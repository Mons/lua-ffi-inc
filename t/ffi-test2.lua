require("ffi-inc")
local ffi = require("ffi")
ffi.include("sys/time.h")

timeval = ffi.typeof("struct timeval");
local hitime = function()
	local tv = timeval();
	ffi.C.gettimeofday(tv,nil);
	return tonumber(tv.tv_sec) + tonumber(tv.tv_usec)/1e6;
end

print("from 2",hitime())

return 2
