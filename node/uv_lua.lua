local uv_lua = {}
local uv = require("uv")

local bit = require("bit")
local ffi = require("ffi")
local bor = bit.bor
local band = bit.band

local registers = {}
local freelist

local function register(cb)
	local id

	if (freelist) then
		id = freelist
		freelist = registers[freelist]
	else
		id = #registers + 1
	end

	registers[id] = cb
	return id
end

local function unregister(id)
	if (id > 0) then
		registers[id] = freelist
		freelist = id
	end
end

function uv_lua.uv_idle_start(handler, callback)
	unregister(tonumber(handler[0].idle_cb_lua))
	return uv.uv_idle_start_lua(handler, register(callback))
end

function uv_lua.uv_idle_stop(handler)
	unregister(tonumber(handler[0].idle_cb_lua))
	handler[0].idle_cb_lua = 0
	uv.uv_idle_stop(handler)
end

function uv_lua.uv_timer_start(handler, callback, timeout, rep)
	unregister(tonumber(handler[0].timer_cb_lua))
	return uv.uv_timer_start_lua(handler, register(callback), timeout or 0, rep or 0)
end

function uv_lua.uv_timer_stop(handler)
	unregister(tonumber(handler[0].timer_cb_lua))
	handler[0].timer_cb_lua = 0
	uv.uv_timer_stop(handler)
end

if (ffi.os == "Windows") then
	local function uv_idle_invoke(loop)
		local handle
		loop.next_idle_handle = loop.idle_handles

		while (loop.next_idle_handle ~= nil) do
			handle = loop.next_idle_handle
			loop.next_idle_handle = handle.idle_next

			-- call here
			registers[handle.idle_cb_lua](handle, 0)
		end
	end

	local function uv_process_timers(loop)
		local handle
		local handle = uv.uv_timer_query_lua(loop)
		while (handle ~= nil) do
			registers[handle.timer_cb_lua](handle, 0)

			handle = uv.uv_timer_query_lua(loop)
		end
	end

	function uv_lua.uv_run(loop, mode)
		while (uv.uv_loop_alive(loop) ~= 0) do
			uv.uv_update_time(loop)

			uv_process_timers(loop);

			-- idle invoke
			if (loop.pending_reqs_tail == nil and
				loop.endgame_handles == nil) then
				uv_idle_invoke(loop)
			end

			-- uv_process_reqs(loop);
			-- uv_process_endgames(loop);
			-- uv_prepare_invoke(loop);

			-- pool

			-- uv_check_invoke(loop)

			if (band(mode, bor(uv.UV_RUN_ONCE, uv.UV_RUN_NOWAIT)) ~= 0) then
				print("return")
				return uv.uv_loop_alive(loop)
			end
		end
	end
else

end

return uv_lua