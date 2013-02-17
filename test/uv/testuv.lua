local uv = require("uv")
local ffi = require("ffi")

local idler = ffi.new("uv_idle_t[1]");

uv.uv_idle_init(uv.uv_default_loop(), idler);

local counter = 0
uv.uv_idle_start(idler, function(handle)
	counter = counter + 1
	if (counter > 10e6) then
		uv.uv_idle_stop(handle)
		print("Exiting... ")
	end
end);

