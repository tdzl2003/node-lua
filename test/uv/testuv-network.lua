local uv = require("uv")
local uv_lua = require("uv_lua")
local ffi = require("ffi")
local buffer = require("buffer")

local loop = uv.uv_default_loop()

local server = ffi.new("uv_tcp_t[1]")
rawset(_G, "server", server)

uv.uv_tcp_init(loop, server)

uv.uv_tcp_bind(server, uv.uv_ip4_addr("0.0.0.0", 7000))

uv_lua.uv_listen(server, 128, function(server, status)
	if (status == -1) then
		print("Error!")
		return
	end

	print("Clients comes!")

	local client = ffi.new("uv_tcp_t[1]")
	uv.uv_tcp_init(loop, client)

	if (uv_lua.uv_accept(server, client) == 0) then
		uv_lua.uv_read_start(client, nil, function(handle, result, buffer)
			if (result > 0) then
				print(result, buffer:toString(nil, 0, result))
			end
		end)
	else
		uv_lua.uv_close(client, NULL)
	end
end)

