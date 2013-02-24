local uv = require("uv")
local uv_lua = require("uv_lua")
local ffi = require("ffi")
local buffer = require("buffer")

-- File system test
-- copy one file to another.

--[[
local loop = uv.uv_default_loop()
local fsreq1 = ffi.new("uv_fs_t[1]")
local fsreq2 = ffi.new("uv_fs_t[1]")
local path1 = ".\\one.txt"
local path2 = ".\\another.txt"
local buf = buffer.new(1024)
local len = 0

local function fs2_onopen(req)
	if (req.result ~= -1) then
		print("open another.txt successful")
		uv.uv_fs_write(uv.uv_default_loop(), req, req.result,
			           buf.data, len, -1, fs2_onwrite)
	end
end

--Here, req.result = 0?

local function fs2_onwrite()
	if (req.result ~= -1) then
		print("write successful")
		uv.uv_fs_close(uv.uv_default_loop(), req, req.result, nil)
		uv.uv_fs_req_cleanup(req)
	end
end

local function fs1_onread(req)
	if (req.result>0) then
		len = req.result
		print(buf:toString(nil,0,len))
		uv.uv_fs_close(uv.uv_default_loop(), req, req.result, nil)
		uv.uv_fs_req_cleanup(req)
		uv.uv_fs_open(uv.uv_default_loop(), fsreq2, path2, uv.O_WRONLY, 0, fs2_onopen)
	end
end

local function fs1_onopen(req)
	if (req.result ~= -1) then
		print("open one.txt successful")
		uv.uv_fs_read(uv.uv_default_loop(), req, req.result,
			          buf.data, buf.size, -1, fs1_onread)
	end
end

uv.uv_fs_open(uv.uv_default_loop(), fsreq1, path1, uv.O_RDONLY, 0, fs1_onopen)

]]

local loop = uv.uv_default_loop()
local path1 = ".\\one.txt"
local path2 = ".\\another.txt"

local buf = buffer.new(1024)
local len

local fsreq1 = ffi.new("uv_fs_t[1]")
uv_lua.uv_fs_open(loop, fsreq1, path1, uv.O_RDONLY, 0, function()
	local file1 = fsreq1[0].result
	uv.uv_fs_req_cleanup(fsreq1)
	uv_lua.uv_fs_read(loop, fsreq1, file1, buf.data, buf.size, -1, function()
		len = fsreq1[0].result
		if (len < 0) then
			error("uv_fs_read error!")
		end
		print("Readed "..len.." bytes")
		uv.uv_fs_req_cleanup(fsreq1)
		uv.uv_fs_close(loop, fsreq1, file1, nil)

		print(buf:toString(nil, 0, len))
	end)
end)
