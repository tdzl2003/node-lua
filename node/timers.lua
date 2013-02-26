local uv = require("uv")
local uv_lua = require("uv_lua")
local ffi = require("ffi")

local aTimerReq = {}
local loop = uv.uv_default_loop()

local uv_timer_t = ffi.typeof("uv_timer_t[1]")

local function setTimeOut(callback, delay, ...)
	local timerID = {}
	aTimerReq[timerID] = ffi.new(uv_timer_t)

	uv.uv_timer_init(loop, aTimerReq[timerID])
	local tf = bind(callback, ...)
	uv_lua.uv_timer_start(aTimerReq[timerID], tf, delay, 0);

	return timerID
end
rawset(_G, "setTimeOut", setTimeOut)

local function clearTimeOut(timeoutID)
	if (aTimerReq[timeoutID] ~= nil) then
		uv_lua.uv_timer_stop(aTimerReq[timeoutID])
		aTimerReq[timeoutID] = nil
	end
end
rawset(_G, "clearTimeOut", clearTimeOut)

local function setInterval(callback, delay, ...)
	local timerID = {}
	aTimerReq[timerID] = ffi.new(uv_timer_t)

	uv.uv_timer_init(loop, aTimerReq[timerID])
	local tf = bind(callback, ...)
	uv_lua.uv_timer_start(aTimerReq[timerID], tf, delay, delay);

	return timerID
end
rawset(_G, "setInterval", setInterval)

local function clearInterval(intervalID)
	if (aTimerReq[intervalID] ~= nil) then
		uv_lua.uv_timer_stop(aTimerReq[intervalID])
		aTimerReq[intervalID] = nil
	end
end
rawset(_G, "clearInterval", clearInterval)
