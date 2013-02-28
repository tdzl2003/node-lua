local uv_lua = {}
local uv = require("uv")

local bit = require("bit")
local ffi = require("ffi")
local bor = bit.bor
local band = bit.band

-- Callback wrap
local registers = {}
local freelist
local count = 0
--callbacks used in process.nextTick
uv_lua.nextTickCallbacks = {}

local function register(cb)
	assert(cb)
	local id

	if (freelist) then
		id = freelist
		freelist = registers[freelist]
	else
		count = count + 1
		id = count
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
	return uv.uv_idle_start_lua(handler, register(callback))
end

function uv_lua.uv_idle_stop(handler)
	unregister(tonumber(handler[0].idle_cb_lua))
	handler[0].idle_cb_lua = 0
	uv.uv_idle_stop(handler)
end

-- Timer functions 
function uv_lua.uv_timer_start(handler, callback, timeout, rep)
	return uv.uv_timer_start_lua(handler, register(callback), timeout or 0, rep or 0)
end

function uv_lua.uv_timer_stop(handler)
	unregister(tonumber(handler[0].timer_cb_lua))
	handler[0].timer_cb_lua = 0
	uv.uv_timer_stop(handler)
end

-- network functions
local p_uv_stream_t = ffi.typeof("uv_stream_t*")
local p_uv_handle_t = ffi.typeof("uv_handle_t*")

function uv_lua.uv_listen(server, backlog, callback)
	return uv.uv_listen_lua(ffi.cast(p_uv_stream_t, server), backlog, register(callback))
end

function uv_lua.uv_accept(server, client)
	return uv.uv_accept(ffi.cast(p_uv_stream_t, server), ffi.cast(p_uv_stream_t, client))
end

function uv_lua.uv_close(handle, callback)
	return uv.uv_close(ffi.cast(p_uv_handle_t, handle), callback)
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

function uv_lua.uv_fs_close(loop, req, file, callback)
	if (callback) then
		return uv.uv_fs_close_lua(loop, req, file, register(callback))
	else
		return uv.uv_fs_close(loop, req, file, nil)
	end
end

function uv_lua.uv_fs_unlink(loop, req, path, callback)
	if (callback) then 
		return uv.uv_fs_unlink_lua(loop, req, path, register(callback))
	else
		return uv.uv_fs_unlink(loop, req, path, nil)
	end
end

function uv_lua.uv_fs_write(loop, req, file, buf, length, offset, callback)
	if (callback) then
		return uv.uv_fs_write_lua(loop, req, file, buf, length, offset, register(callback))
	else
		return uv.uv_fs_write(loop, req, file, buf, length, offset, nil)
	end
end

function uv_lua.uv_fs_mkdir(loop, req, path, mode, callback)
	if (callback) then
		return uv.uv_fs_mkdir_lua(loop, req, path, mode, register(callback))
	else
		return uv.uv_fs_mkdir(loop, req, path, mode, nil)
	end
end

function uv_lua.uv_fs_rmdir(loop, req, path, callback)
	if (callback) then
		return uv.uv_fs_rmdir_lua(loop, req, path, callback)
	else
		return uv.uv_fs_rmdir(loop, req, path, nil)
	end
end

function uv_lua.uv_fs_readdir(loop, req, path, flags, callback)
	if (callback) then
		return uv.uv_fs_readdir_lua(loop, req, path, flags, register(callback))
	else
		return uv.uv_fs_readdir(loop, rea, path, flags, nil)
	end
end

function uv_lua.uv_fs_stat(loop, req, path, callback)
	if (callback) then
		return uv.uv_fs_stat_lua(loop, req, path, register(callback))
	else
		return uv.uv_fs_stat(loop, req, path, nil)
	end
end

function uv_lua.uv_fs_fstat(loop, req, file, callback)
	if (callback) then
		return uv.uv_fs_fstat_lua(loop, req, file, register(callback))
	else
		return uv.uv_fs_fstat(loop, req, file, nil)
	end
end

function uv_lua.uv_fs_rename(loop, req, path, new_path, callback)
	if (callback) then
		return uv.uv_fs_rename_lua(loop, req, path, new_path, register(callback))
	else
		return uv.uv_fs_rename(loop, req, path, new_path, nil)
	end
end

function uv_lua.uv_fs_fsync(loop, req, file, callback)
	if (callback) then
		return uv.uv_fs_fsync_lua(loop, req, file, register(callback))
	else
		return uv.uv_fs_fsync(loop, req, file, nil)
	end
end

function uv_lua.uv_fs_fdatasync(loop, req, file, callback)
	if (callback) then
		return uv.uv_fs_fdatasync_lua(loop, req, file, register(callback))
	else
		return uv.uv_fs_fdatasync(loop, req, file, nil)
	end
end

function uv_lua.uv_fs_ftruncate(loop, req, file, offset, callback)
	if (callback) then
		return uv.uv_fs_ftruncate_lua(loop, req, file, offset, register(callback))
	else
		return uv.uv_fs_ftruncate(loop, req, file, offset, nil)
	end
end

function uv_lua.uv_fs_sendfile(loop, req, out_fd, in_fd, in_offset, length, callback)
	if (callback) then
		return uv.uv_fs_sendfile_lua(loop, req, out_fd, in_fd, in_offset, length, register(callback))
	else
		return uv.uv_fs_sendfile(loop, req, out_fd, in_fd, in_offset, length, nil)
	end
end

function uv_lua.uv_fs_chmod(loop, req, path, mode, callback)
	if (callback) then
		return uv.uv_fs_chmod_lua(loop, req, path, mode, register(callback))
	else
		return uv.uv_fs_chmod(loop, req, path, mode, nil)
	end
end

function uv_lua.uv_fs_utime(loop, req, path, atime, mtime, callback)
	if (callback) then
		return uv.uv_fs_utime_lua(loop, req, path, atime, mtime, register(callback))
	else
		return uv.uv_fs_utime(loop, req, path, atime, mtime, nil)
	end
end

function uv_lua.uv_fs_futime(loop, req, file, atime, mtime, callback)
	if (callback) then
		return uv.uv_fs_futime_lua(loop, req, file, atime, mtime ,register(callback))
	else
		return uv.uv_fs_futime(loop, req, file, atime, mtime, nil)
	end
end

function uv_lua.uv_fs_lstat(loop, req, path, callback)
	if (callback) then
		return uv.uv_fs_lstat_lua(loop, req, path, register(callback))
	else
		return uv.uv_fs_lstat(loop, req, path, nil)
	end
end

function uv_lua.uv_fs_link(loop, req, path, new_path, callback)
	if (callback) then 
		return uv.uv_fs_link_lua(loop, req, path, new_path, register(callback))
	else
		return uv.uv_Fs_link(loop, req, path, new_path, nil)
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

	local p_uv_tcp_t = ffi.typeof("uv_tcp_t*")
	local function uv_process_tcp_accept_req(loop, handle, raw_req)
		local result = uv.uv_preprocess_tcp_accept_req(loop, handle, raw_req)

		-- result 1 means ignore here.
		if (result <= 0) then
			registers[handle.connection_cb_lua](handle, result)

			if (result < 0) then
				-- some error occured. stop listening.
				unregister(handle.connection_cb_lua)
				handle.connection_cb_lua = 0
			end
		end
	end

	local function uv_process_accept_req(loop, req)
		local handle = ffi.cast(p_uv_handle_t, req.data)
		local type = handle.type

		if (type == uv.UV_TCP) then
			uv_process_tcp_accept_req(loop, ffi.cast(p_uv_tcp_t, handle), req)
		--elseif (type == uv.UV_NAMED_PIPE) then
		--elseif (type == uv.UV_TTY) then
		else
			error("Unsupported handle type!" .. tostring(type))
		end
	end

	local p_uv_fs_t = ffi.typeof("uv_fs_t*")
	local function uv_process_fs_req(loop, req)
		req = ffi.cast(p_uv_fs_t, req)
		assert(req.cb_lua ~= 0)
		uv.uv_preprocess_fs_req(loop, req)
		local f = registers[req.cb_lua]
		unregister(req.cb_lua)
		req.cb_lua = 0
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
			elseif (type == uv.UV_ACCEPT) then
				uv_process_accept_req(loop, req)
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
				error ("Unsupported req type!" .. tostring(type))
			end

		end
	end

	local function uv_tcp_endgame(loop, handle)
		local tcphandle = ffi.cast(p_uv_tcp_t, handle)
		-- TODO: shutdown
		if (uv.uv_tcp_endgame_step2_lua(loop, tcphandle) ~= 0) then
		end
	end

	local function uv_process_endgames(loop)
		local handle
		while (loop.endgame_handles ~= nil) do
			handle = loop.endgame_handles
			loop.endgame_handles = handle.endgame_next
			handle.flags = band(handle.flags, 0xFFFFFFFB)

			local type = handle.type

			if (type == uv.UV_TCP) then
				uv_tcp_endgame(loop, handle)
			-- elseif (type == uv.UV_NAMED_PIPE) then
			-- elseif (type == uv.UV_TTY) then
			-- elseif (type == uv.UV_UDP) then
			-- elseif (type == uv.UV_POLL) then
			-- elseif (type == uv.UV_TIMER) then
			-- elseif (type == uv.UV_PREPARE or type == uv.UV_CHECK or type == uv.UV_IDLE) then
			-- elseif (type == uv.UV_ASYNC) then
			-- elseif (type == uv.UV_SIGNAL) then
			-- elseif (type == uv.UV_PROCESS) then
			-- elseif (type == uv.UV_FS_EVENT) then
			-- elseif (type == uv.UV_FS_POLL) then
			else
				error("Unsupported handle type!" .. tostring(type))
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

			-- do all callbacks in nextTickCallbacks
			local t = {}
			for i, v in pairs(nextTickCallbacks) do
				t[i] = nextTickCallbacks[i]
				nextTickCallbacks[i] = nil
			end

			for i,v in pairs(t) do
				xpcall(t[i], function()
					error("Unexpected error in nextTick callbacks.")
				end)
			end

			uv_process_reqs(loop);
			uv_process_endgames(loop);
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