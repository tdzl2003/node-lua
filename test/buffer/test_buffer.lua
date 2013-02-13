require("buffer")

-- test of creation, write, tostring
local buf = Buffer.new(40)
buf:fill(32)		-- fill with space
buf:write("Hello, buffer in Node.lua")
local buf1 = Buffer.new(buf)
buf:write("Replaced content.")
local buf2 = Buffer.new("中国字")
buf2:write(buf)

print(buf.size, buf1.size, buf2.size)	-- 40 40 9
print(buf, buf1, buf2)
print(Buffer.isBuffer(buf))

-- test of empty Buffer
local emptyBuffer = Buffer.new(0)
print(emptyBuffer.size)

print(Buffer.isBuffer(emptyBuffer))

-- test of Buffer.concat
print(Buffer.concat({buf, buf1, buf2, emptyBuffer}))

-- test of indexed accessing
print(buf[0], buf[1], string.byte("Re", 1, 2))
buf[0] = 72
print(buf)

-- test of Buffer.copy
buf = Buffer.new("123456789")
buf:copy(buf, 1)
print(buf)
buf = Buffer.new("123456789")
buf:copy(buf, 0, 1)
print(buf)

-- test of readUInt8
buf = Buffer.new({00, 01, 02, 0x83})
print(buf:readUInt8(2))

-- test of readUInt16
print(buf:readUInt16LE(0))
print(buf:readUInt16BE(0))
print(buf:readUInt32LE(0))
print(buf:readUInt32BE(0))

print(buf:readInt16LE(2))
print(buf:readInt16BE(2))
print(buf:readInt32LE(0))
print(buf:readInt32BE(0))