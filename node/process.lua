local event = require("event")
local EventEmitter = event.EventEmitter
local Dispatcher = event.Dispatcher

local path = require("path")

local uv = require("uv")
local uv_lua = require("uv_lua")
local buffer = require("buffer")

local loop = uv.uv_default_loop()

local ffi = require("ffi")
ffi.cdef [[
    void __cdecl exit(int _Code);
    int _chdir (const char *dirname);
]]
local C = ffi.C

local process = EventEmitter.new()
process.evExit = Dispatcher.new()

process.argv     = arg
process.execPath = arg[-1]

process.chdir = function(directory)
	local ret = C._chdir(directory)
	if (ret == -1) then
		error("process.chdir failed!")
	end
end

process.cwd = path.current()
process.getenv = os.getenv

process.exit = function(code)
	process.evExit()
	C.exit(code or 0)
end

local tb = buffer.new(256)
local function getProcessTitle()
	uv.uv_get_process_title(tb.data, tb.size)
	return tostring(tb)
end
process.title = getProcessTitle()

process.hrtime = function()
	local t = uv_hrtime()
	local ret = {}
	ret[1] = tonumber(t/1e9)
	ret[2] = tonumber(t%1e9)
	return ret
end

return process