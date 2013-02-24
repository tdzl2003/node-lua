local ffi = require("ffi")
local bswap = bit.bswap

local wkt = {__mode = "k"}
local wvt = {__mode = "v"}
local wwt = {__mode = "kv"}
function newWeakKeyTable()
	local ret = {}
	setmetatable(ret, wkt)
	return ret
end

function newWeakValueTable()
	local ret = {}
	setmetatable(ret, wvt)
	return ret
end

function newWholeWeakTable()
	local ret = {}
	setmetatable(ret, wwt)
	return ret
end

ffi.cdef[[
	typedef union{
		float floatValue;
		int   intValue;
	} floatu;
]]
local floatunion = ffi.new("floatu")

function intToFloatByBit(i)
	floatunion.intValue = i
	return floatunion.floatValue
end

function floatToIntByBit(f)
	floatunion.floatValue = f
	return floatunion.intValue
end

function floatBSwap(f)
	floatunion.floatValue = f
	floatunion.intValue = bswap(floatunion.intValue)
	return floatunion.floatValue
end

ffi.cdef[[
	typedef union{
	    int int32Value[2];
		long long llValue;
	} int64u;
]]
local int64u = ffi.new("int64u")

function int64BSwap(i)
	int64u.llValue = i
	local t = bswap(int64u.int32Value[0])
	local u = bswap(int64u.int32Value[1])
	int64u.int32Value[0] = u
	int64u.int32Value[1] = t
	return int64u.llValue
end

ffi.cdef[[
	typedef union{
		long long llValue;
		double dValue;
	} doubleu;
]]
local doubleu = ffi.new("doubleu")

function doubleBSwap(d)
	doubleu.dValue = d
	doubleu.llValue = int64BSwap(doubleu.llValue)
	return doubleu.dValue
end

-- limit global newindex
-- only rawset(_G, key, value) is allowed.
setmetatable(_G, {
		__newindex = function (t, k, v)
			print("Warning: writing global variant "..k)
			rawset(t, k, v)
		end
	})