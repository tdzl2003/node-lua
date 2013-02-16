local assert_ = {}

assert_.ok = assert

setmetatable(assert_, {
	__call = function(t, ...)
		assert(...)
	end
	})

function assert_.fail(actual, expected, message, operator)
	error(message..actual..operator..expected)
end

function assert_.equal(actual, expected, message)
	if (actual ~= expected) then
		error(message or "assertion failed!")
	end
end

function assert_.notEqual(actual, expected, message)
	if (actual == expected) then
		error(message or "assertion failed!")
	end
end

function assert_.throws(block, error_, message)
	local re, msg = pcall(block)
	if (re) then
		if (error_ == nil or 
			(type(error_) == "string" and msg:match(error_)) or
			(type(error_) == "function" and error_(msg))) then
			return
		end
	end
	error(message or "assertion failed!")
end

function assert_.doesNotThrow(block, error_, message)
	local re, msg = pcall(block)
	if (re) then
		if (error_ == nil or 
			(type(error_) == "string" and msg:match(error_)) or
			(type(error_) == "function" and error_(msg))) then
			error(message or "assertion failed!")
		end
	end
end

function assert_.ifError(value)
	if (value) then
		error("assertion failed!")
	end
end

function assert_.deepEqual(actual, expected, message)
	--todo
end

return assert_