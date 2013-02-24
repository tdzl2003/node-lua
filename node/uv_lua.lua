local uv_lua = {}
local uv = require("uv")

local bit = require("bit")
local ffi = require("ffi")
local bor = bit.bor
local band = bit.band

-- Callback wrap
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


-- Idle functions
function uv_lua.uv_idle_start(handler, callback)
	unregister(tonumber(handler[0].idle_cb_lua))
	return uv.uv_idle_start_lua(handler, register(callback))
end

function uv_lua.uv_idle_stop(handler)
	unregister(tonumber(handler[0].idle_cb_lua))
	handler[0].idle_cb_lua = 0
	uv.uv_idle_stop(handler)
end

-- Timer functions 
function uv_lua.uv_timer_start(handler, callback, timeout, rep)
	unregister(tonumber(handler[0].timer_cb_lua))
	return uv.uv_timer_start_lua(handler, register(callback), timeout or 0, rep or 0)
end

function uv_lua.uv_timer_stop(handler)
	unregister(tonumber(handler[0].timer_cb_lua))
	handler[0].timer_cb_lua = 0
	uv.uv_timer_stop(handler)
end

-- fs functions
function uv_lua.uv_fs_open(loop, req, path, flag, mode, callback)
	if (callback) then
		return uv.uv_fs_open_lua(loop, req, path, flag, mode, register(callback))
	else
		return uv.uv_fs_open(loop, req, path, flag, mode, nil)
	end
end

function uv_lua.uv_fs_read(loop, req, file, buf, len, ofs, callback)
	if (callback) then
		return uv.uv_fs_read_lua(loop, req, file, buf, len, ofs, register(callback))
	else
		return uv.uv_fs_read(loop, req, file, buf, len, ofs, nil)
	end
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

	local p_uv_fs_t = ffi.typeof("uv_fs_t*")
	local function uv_process_fs_req(loop, req)
		req = ffi.cast(p_uv_fs_t, req)
		assert(req.cb_lua ~= 0)
		uv.uv_preprocess_fs_req(loop, req)
		local f = registers[req.cb_lua]
		unregister(req.cb_lua)
		f(req)
	end

	local function uv_process_reqs(loop)
		local req, first, next

		if (loop.pending_reqs_tail == nil) then
			return
		end

		first = loop.pending_reqs_tail.next_req
		next = first
		loop.pending_reqs_tail = NULL
		while (next ~= nil) do
			req = next
			next = req.next_req
			if (next == first) then
				next = nil
			end

			local type = req.type
			if (false) then
			-- TODO:
			-- elseif (type == uv.UV_READ) then
			-- elseif (type == uv.UV_WRITE) then
			-- elseif (type == uv.UV_ACCEPT) then
			-- elseif (type == uv.UV_CONNECT) then
			-- elseif (type == uv.UV_SHUTDOWN) then
			-- elseif (type == uv.UV_UDP_RECV) then
			-- elseif (type == uv.UV_UDP_SEND) then
			-- elseif (type == uv.UV_WAKEUP) then
			-- elseif (type == uv.UV_SIGNAL_REQ) then
			-- elseif (type == uv.UV_POLL_REQ) then
			-- elseif (type == uv.UV_GETADDRINFO) then
			-- elseif (type == uv.UV_PROCESS_EXIT) then
			elseif (type == uv.UV_FS) then
				uv_process_fs_req(loop, req)
			-- elseif (type == uv.UV_WORK) then
			-- elseif (type == uv.UV_FS_EVENT_REQ) then
			else
				error ("Unsupported req type!")
			end

		end
	end

	local function uv_poll(loop, block)
		uv.uv_poll(loop, block and 1 or 0)
	end

	local function uv_poll_ex(loop, block)
		uv.uv_poll_ex(loop, block and 1 or 0)
	end

	local function getPollFunc(loop)
		if (uv.isPoolExAvailable(loop) ~= 0) then
			return uv_poll_ex
		else
			return uv_poll
		end
	end

	local poll

	function uv_lua.uv_run(loop, mode)
		poll = poll or getPollFunc(loop)

		while (uv.uv_loop_alive(loop) ~= 0) do
			uv.uv_update_time(loop)

			uv_process_timers(loop);

			-- idle invoke
			if (loop.pending_reqs_tail == nil and
				loop.endgame_handles == nil) then
				uv_idle_invoke(loop)
			end

			uv_process_reqs(loop);
			-- uv_process_endgames(loop);
			-- uv_prepare_invoke(loop);

			poll(loop, 
				loop.idle_handles == nil and
				loop.pending_reqs_tail == nil and
				loop.endgame_handles == nil and
				uv.uv_loop_alive(loop) ~= 0 and
				band(mode, uv.UV_RUN_NOWAIT) == 0);

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