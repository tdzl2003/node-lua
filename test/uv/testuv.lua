local uv = require("uv")
local uv_lua = require("uv_lua")
local ffi = require("ffi")
local buffer = require("buffer")

--Idle test
--[[
local start = uv.uv_hrtime()

local counter = 0

local idlers = {}
rawset(_G, "idlers", idlers)
for i = 1, 1000 do

	local function wait_for_a_while(handle, status) 
	    counter = counter + 1
	    if (counter >= 1e5) then
	        uv_lua.uv_idle_stop(handle)
	    end
	end

	local idler = ffi.new("uv_idle_t[1]")
	idlers[i] = idler
	uv.uv_idle_init(uv.uv_default_loop(), idler)
	uv_lua.uv_idle_start(idler, wait_for_a_while)
end

print("Idling")
uv_lua.uv_run(uv.uv_default_loop(), uv.UV_RUN_DEFAULT)


print(tonumber(uv.uv_hrtime() - start) / 1000000000)
]]

-- idle 1e6 times:
-- takes 3.2239s before optimize.
-- 0.013s after optimize.


local timer = ffi.new("uv_timer_t[1]")
uv.uv_timer_init(uv.uv_default_loop(), timer)
local counter = 0

uv_lua.uv_timer_start(timer, function(handler, status)
	print("Hello, timer!")
	counter = counter + 1
	if (counter >= 5) then
		uv_lua.uv_timer_stop(handler)
	end
end, 500, 500)

