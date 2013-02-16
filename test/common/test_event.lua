local event = require("event")

local ev = event.Dispatcher.new()

ev()


ev:on(function()
	print("here1")
end)

-- test of weak listener
ev:on(function()
	print("here2")
end, true)

ev()
collectgarbage()
ev() -- will not print here2 again.

print()

ev:removeAllListeners()

ev:once(function()
	print("-- once!")
end)

for i = 1, 5 do 
	ev:once(function()
		print("-- once everytime")
	end)
	ev()
end

print(#ev:listeners())


local emitter = event.EventEmitter.new()
emitter.event = event.Dispatcher.new()
emitter:addListener('event', function()
		print("here1")
	end)

emitter:once('event', function()
		print('once')
	end)

emitter:emit('event')
emitter:emit('event')
