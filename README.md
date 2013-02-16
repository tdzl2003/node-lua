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

	Direct call to "assert_" is deprecated, call "assert" or "assert_.ok" instead.

