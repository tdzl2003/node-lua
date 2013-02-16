--TODO: do "single-listener" optimize.
--TODO: implement setMaxListeners method which helps finding memory leaks.

require("lua_ex")
local newWeakValueTable = newWeakValueTable
local newWeakKeyTable = newWeakKeyTable

local Dispatcher = {
}

Dispatcher.__index = Dispatcher

function Dispatcher.new()
	local ret = {
		newWeakValueTable(),			-- listener sorted list
		newWeakKeyTable(),				-- listener index map
		{},								-- non-weak listener container
		0,								-- size of list
		newWeakKeyTable(), 				-- once table, nil means once. non-nil value means sustained.
	}
	setmetatable(ret, Dispatcher)
	return ret
end

local function removeListener(self, listener)
	local id = self[2][listener]
	if (id) then
		self[1][id] = nil
		self[2][listener] = nil
		self[3][listener] = nil
		self[5][listener] = nil
	end
end
Dispatcher.removeListener = removeListener

local function clearUp(self)
	local list = self[1]
	local map = self[2]

	local j = 0
	for i = 1, self[4] do 
		if (list[i]) then
			j = j + 1
			if (i > j) then
				list[j] = list[i]
				map[list[i]] = j
				list[i] = nil
			end
		end
	end

	self[4] = j
end

function Dispatcher:call(...)
	clearUp(self)
	local list = self[1]
	local once = self[5]

	for i = 1, self[4] do
		-- still need nil guard here.
		if (list[i]) then
			local f = list[i]
			if (not once[f]) then
				removeListener(self, f)
			end

			f(...)
		end
	end
end

Dispatcher.__call = Dispatcher.call

local function addListener(self, listener, isWeak, once)
	if (not once) then
		self[5][listener] = true
	end
	if (not isWeak) then
		self[3][listener] = true
	end

	local map = self[2]
	if (map[listener]) then
		return
	end
	local list = self[1]
	self[4] = self[4] + 1
	list[self[4]] = listener
	map[listener] = self[4]
	return self
end

function Dispatcher:addListener(listener, isWeak)
	return addListener(self, listener, isWeak, false)
end
Dispatcher.on = Dispatcher.addListener

function Dispatcher:once(listener, isWeak)
	return addListener(self, listener, isWeak, true)
end

function Dispatcher:removeAllListeners()
	for i = 1, self[4] do 
		if (self[1][i]) then
			removeListener(self, self[1][i])
		end
	end
end

function Dispatcher:listeners()
	clearUp(self)
	local ret = {}
	for i = 1, self[4] do 
		ret[i] = self[1][i]
	end
	return ret
end

local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter:addListener(event, listener, isWeak)
	local dis = self[event] or error("Invalid event name"..event)
	dis:addListener(listener, isWeak)
	return self
end
EventEmitter.on = EventEmitter.addListener

function EventEmitter:once(event, listener, isWeak)
	local dis = self[event] or error("Invalid event name"..event)
	dis:once(listener, isWeak)
	return self
end

function EventEmitter:removeListener(event, listener)
	local dis = self[event] or error("Invalid event name"..event)
	dis:removeListener(listener)
	return self
end

function EventEmitter:removeAllListeners(event)
	local dis = self[event] or error("Invalid event name"..event)
	dis:removeAllListeners()
	return self
end

function EventEmitter:listeners(event)
	local dis = self[event] or error("Invalid event name"..event)
	return dis:listeners()
end

function EventEmitter:emit(event, ...)
	local dis = self[event] or error("Invalid event name"..event)
	dis(...)
	return self
end

function EventEmitter.new()
	local ret = {}
	setmetatable(ret, EventEmitter)
	return ret
end

local event = {
	Dispatcher = Dispatcher,
	EventEmitter = EventEmitter, 
}

return event
