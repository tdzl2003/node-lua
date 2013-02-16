local assert_ = {}

assert_.ok = assert

setmetatable(assert_, {
	__call = function(t, ...)
		assert(...)
	end
	})

return assert_