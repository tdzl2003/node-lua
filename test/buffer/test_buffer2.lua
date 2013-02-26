local uv = require("uv")
local ffi = require("ffi")
local buffer = require("buffer")
local bswap = bit.bswap
require("lua_ex")


--Idle test

--[[
local counter = 0;

function wait_for_a_while(handle, status) 
    counter = counter + 1
    if (counter >= 1000000) then
        uv.uv_idle_stop(handle)
    end
end

local idler = ffi.new("uv_idle_t[1]")

uv.uv_idle_init(uv.uv_default_loop(), idler)
uv.uv_idle_start(idler, wait_for_a_while)

print("Idling")
uv.uv_run(uv.uv_default_loop(), uv.UV_RUN_DEFAULT)
]]

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
]]--

-- test
--[[
local i = 10000
local f = intToFloatByBit(i)
print(i,f)

i = bswap(i)
local f2 = intToFloatByBit(i)
local f3 = floatBSwap(f)
print(i,f2,f3)

local i64 = ffi.new("long long")
i64 = ffi.cast("long long", 1)

print(type(i64))
print(i64)
i64 = int64BSwap(i64)
print(i64)]]--

local tb = Buffer.newWithSize(3000)
tb:writeUInt16LE(40000, 0)
tb:writeUInt16BE(40001, 2)
tb:writeInt16LE(20000, 4)
tb:writeInt16BE(20001, 6)

tb:writeUInt32LE(4000000000, 10)
tb:writeUInt32BE(4000000001, 14)
tb:writeInt32LE(2000000000, 18)
tb:writeInt32BE(2000000001, 22)

tb:writeUInt64LE(9300000000000000000, 30)
tb:writeUInt64BE(12345670000000000000, 38)
tb:writeInt64LE(93000000000000, 46)
tb:writeInt64BE(-93000000000001, 54)

tb:writeFloatLE(1.5,  70)
tb:writeFloatBE(-math.sin(math.pi/4)*2, 74)   --sqrt(2)
tb:writeDoubleLE(math.pi, 80)
tb:writeDoubleBE(-math.pi+1,90)

local k = {}
k[1] = tb:readUInt16LE(0)
k[2] = tb:readUInt16BE(2)
k[3] = tb:readInt16LE(4)
k[4] = tb:readInt16BE(6)

k[5] = tb:readUInt32LE(10)
k[6] = tb:readUInt32BE(14)
k[7] = tb:readInt32LE(18)
k[8] = tb:readInt32BE(22)

k[9]  = tb:readUInt64LE(30)
k[10] = tb:readUInt64BE(38)
k[11] = tb:readInt64LE(46)
k[12] = tb:readInt64BE(54)

k[13] = tb:readFloatLE(70)
k[14] = tb:readFloatBE(74)
k[15] = tb:readDoubleLE(80)
k[16] = tb:readDoubleBE(90)

for i=1, #k do
	--print(tonumber(k[i]))
end

local start = uv.uv_hrtime()

for i=1, 100000000 do
	tb:writeDoubleBE(12345670000000000000.5, 0)
	tb:readDoubleBE(0)
end
print(tonumber(uv.uv_hrtime() - start) / 1000000000) 

