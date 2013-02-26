local uv = require("uv")
local uv_lua = require("uv_lua")
local ffi = require("ffi")
local buffer = require("buffer")
local timers = require("timers")


local function testfunction1()
	print("Helloworld!")
end

local function testfunction2(i)
	print("Print:"..i)
end

setInterval(testfunction1, 1000)
setInterval(testfunction2, 500, 40)


