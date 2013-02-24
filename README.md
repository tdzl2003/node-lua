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

	Buffer.new() can be used, but these followed functions is recommended:

		* Buffer.newWithSize(size)

		* Buffer.newWithString(str)

		* Buffer.newWithArray(array)

Assert:

	Package "assert" is renamed as "assert_" in Node.lua.

	Direct call to "assert_" is available, but call "assert" or "assert_.ok" is recommended.

	assert.strictEqual,
	assert.notStrictEqual in node.js are REMOVED.

Event:

	There is another class "event.Dispatcher". Code line:

	emitter:addListener("eventName", listener)

	can be replaced with this line:

	emitter.eventName:addListener(listener)

	Of the two the latter is faster than the former. You also can cache the event dispatcher object(emitter.eventName) for later usage.

	Similarly, you can use these methods:

		* emitter.eventName:addListener(listener[, isWeak])

		* emitter.eventName:on(listener[, isWeak])

		* emitter.eventName:once(listener[, isWeak])

		* emitter.eventName:removeListener(listener)

		* emitter.eventName:removeAllListeners()

		* emitter.eventName:listeners()

		* emitter.eventName([arg1], [arg2], [...])

		* emitter.eventName:call([arg1], [arg2], [...])

	Directly call the dispatcher is same as use call method. It's as same as emitter:emit(eventName, [arg1], [arg2], [...])

	Event: 'newListener' for emitter is REMOVED.

	Node.lua add "isWeak" parameter to method addListener/on/once on both emitter and event dispatcher. If this parameter was provided as a non-false value(i.e., any value except nil and false), the listener will be added as weak. It can be collected if there's no other references. After collected, it will be automatically removed from dispatcher.

	Method listeners() in Node.lua will **always return a copy**. In your programs, please do not modify the EventEmitter listeners using array methods. Always use the 'on' method to add new listeners and 'removeListener' method to remove listeners.

	There's a behavior change from Node.js: Add same listener twice into one Dispatcher, the second one will be ignored:

		* If a listener was added again with same property(weak or not, once or not), only the older will be kept.

		* If a weak listener was added again as non-weak listener, the old one will become non-weak and be kept.

		* If a once listener was added again with :on or :addListener, the old one will become sustained.

		* If a non-weak listener was added again as weak listener, or a sustained listener was added again as once listener, the old one will be kept unchanged.

		* If a weak sustained listener was added again as a non-weak once listener, or a non-weak once listener was added again as a weak sustained listener, the old one will become non-weak sustained.

		* Just remember the elder one will be always keeped, with the most stable property ever provided.

	Not only function can be used as listener, userdata/table with a __call metamethod also can be added to a event dispatcher. e.g.: another event dispatcher object.

		* Add a event dispatcher object to itself is legal, but the infinite recursion may cause stack overflow error.

		* Add a event dispatcher object to itself with "once" method is legal and executable. It will be removed before it's called, so the recursion will not be infinite.

	Method "removeListener" is special optimized in Node.lua. It's quite recommended to add a listener when needed, and to remove it when it's no longer needed. This will get better performance than write a conditional statement in listener function.

	In method EventEmitter:removeAllListeners(event), argument event is not optional.

	EventEmitter:setMaskListeners() is not available currently.

Different with libuv:
-------
	Some new C source files were added into libuv branch at [libuv branch for node.lua](https://github.com/tdzl2003/libuv), and some struct definitions were changed.
	Call function implemented in module uv_lua instead whenever it's possible. This module solved the callback performance issue in luajit. They all have same declaration, but run 100-300 times faster. DONOT mixed use the uv version and the uv_lua version! This may cause crash or other errors.
		* You must call uv_xxxx_stop(handler) function before let them is collected.
	See [FFI Semantics](http://luajit.org/ext_ffi_semantics.html#callback_performance) for more information.
	Field "data" in each req/handler is reserved for libuv. DO NOT modify them.
