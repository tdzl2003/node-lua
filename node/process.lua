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
    DWORD GetCurrentProcessId(void);
    void abort(void);
]]
local C = ffi.C

local process = EventEmitter.new()
process.evExit = Dispatcher.new()
process.evuncaughtException = Dispatcher.new()

--Signal Events
process.evSIGHUP         = Dispatcher.new()
process.evSIGINT	     = Dispatcher.new()
process.evSIGILL         = Dispatcher.new()
process.evSIGABRT_COMPAT = Dispatcher.new()
process.evSIGFPE         = Dispatcher.new()
process.evSIGKILL        = Dispatcher.new()
process.evSIGSEGV        = Dispatcher.new()
process.evSIGTERM        = Dispatcher.new()
process.evSIGBREAK       = Dispatcher.new()
process.evSIGABRT        = Dispatcher.new()
process.evSIGWINCH       = Dispatcher.new() 

process.argv     = arg
process.execPath = arg[-1]

process.abort = function()
	C.abort()
end

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

process.SIGHUP         = 1
process.SIGINT	       = 2
process.SIGILL         = 4
process.SIGABRT_COMPAT = 6
process.SIGFPE         = 8
process.SIGKILL        = 9 
process.SIGSEGV        = 11
process.SIGTERM        = 15
process.SIGBREAK       = 21
process.SIGABRT        = 22
process.SIGWINCH       = 28

local signalMap = {
	"SIGHUP","SIGINT","","SIGILL","","SIGABRT_COMPAT","","SIGFPE","SIGKILL","",
	"SIGSEGV","","","","SIGTERM","","","","","",
	"SIGBREAK","SIGABRT","","","","","","SIGWINCH"
}

process.kill = function(pid, signal)
	local ssignal = signalMap[signal]
	uv.uv_kill(pid, ssignal)
end

process.pid = C.GetCurrentProcessId()

local tb = buffer.new(256)
local function getProcessTitle()
	uv.uv_get_process_title(tb.data, tb.size)
	return tostring(tb)
end
process.title = getProcessTitle()
process.arch  = jit.arch
--process.platform is different with the same process.platform in node.js 
process.platform = jit.os

--remove heapTotal,heapUsed. add memoryUsed.
local pst = ffi.new("size_t[1]")
process.memoryUsage = function()
	local ret = {}
	local mu = collectgarbage("count")
	ret.memoryUsed = mu

	uv.uv_resident_set_memory(pst)
	ret.rss = pst[0]

	return ret
end

local nextTickCb = {}
process.nextTick = function(callback)
	local l = #uv_lua.nextTickCallbacks
	uv_lua.nextTickCallbacks[l+1] = callback
end

local systemStartTime = uv.uv_hrtime()
process.uptime = function()
	return (tonumber(uv.uv_hrtime() - systemStartTime)/1e9)
end

process.hrtime = function()
	local t = uv_hrtime()
	local ret = {}
	ret[1] = tonumber(t/1e9)
	ret[2] = tonumber(t%1e9)
	return ret
end

return process