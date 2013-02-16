Node.lua
========

Description
-----------

Node.lua is evented I/O framework for LuaJIT

Node.lua is a language port of Node.js(https://github.com/joyent/node) project, but reimplemented in Lua language.

Node.lua is licenced at BSD New license. Read LICENCE.md for more information.

Documentation
-------------


Installation
------------


History
-------


Different with Node.js
-------

Buffer:

	Buffer.new() can be used, but these followed functions is recommend:

		* Buffer.newWithSize(size)

		* Buffer.newWithString(str)

		* Buffer.newWithArray(array)

Assert:

	Package "assert" is renamed as "assert_" in Node.lua.

	Direct call to "assert_" is available, but call "assert" or "assert_.ok" is faster.

Event:

	There is another class "event.Dispatcher". Code line:

	emitter:addListener(eventName, listener)

	can be replaced with this line:

	emitter.eventName:addListener(listener)

	Of the two the latter is faster than the former. You also can cache the event dispatcher object(emitter.eventName) for later usage.

	Similarly, you can use these methods:

	* emitter.eventName:on(listener)

	* emitter.eventName:once(listener)

	* emitter.eventName:removeListener(listener)

	* emitter.eventName:removeAllListeners()

	* emitter.eventName:listeners()

	* emitter.eventName([arg1], [arg2], [...])

	* emitter.eventName:call([arg1], [arg2], [...])

	Directly call the dispatcher is same as use call method. 

	Event: 'newListener' for emitter is removed.

