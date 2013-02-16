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

