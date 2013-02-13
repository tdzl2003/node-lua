--TODO: Buffer class should be more effective. implement memorystream/bytearray or such thing for more usability.
--TODO: encoding support
--TODO: write lua preprocessor or something to enable/disable debugging crashes caused by ffi.
--TODO: Buffer.slice cannot be implement now. solve it.

local ffi = require("ffi")

local bit = require("bit")
local bswap = bit.bswap
local lshift = bit.lshift
local tobit = bit.tobit


ffi.cdef[[
	typedef struct {
		uint8_t*	data;
		size_t		size;
	} buffer;

	void* malloc(size_t size);
	void free(void* data);
]]
local bufferCT = ffi.typeof("buffer")

local C = ffi.C

local Buffer = {}
local bufferMT = {
	--__index = Buffer,
}

local function writeString(self, data, ofs, len, encoding)
	ofs = ofs or 0
	len = len or #data
	assert(ofs >= 0 and len >= 0, "Invalid argument!")
	len = math.min(len, #data, self.size - ofs)
	if (len > 0) then
		ffi.copy(self.data + ofs, data, len)
		return len
	end
	return 0
end

Buffer.writeString = writeString

local function writeBuffer(self, buf, ofs, len)
	ofs = ofs or 0
	len = len or buf.size
	assert(ofs >= 0 and len >= 0, "Invalid argument!")
	len = math.min(len, buf.size, self.size - ofs)
	if (len > 0) then
		ffi.copy(self.data + ofs, buf.data, len)
		return len
	end
	return 0
end

Buffer.writeBuffer = writeBuffer

function Buffer:write(data, ...)
	if (type(data) == 'string') then
		return writeString(self, data, ...)
	elseif (ffi.istype(bufferCT, data)) then
		return writeBuffer(self, data, ...)
	else
		error("Invalid argument!")
	end
end

function Buffer:fill(value, ofs, endPos)
	ofs = math.max(ofs or 0, 0)
	endPos = math.min(endPos or self.size, self.size)
	if (endPos > ofs) then
		ffi.fill(self.data + ofs, endPos - ofs, value)
	end
end

function Buffer:copy(target, tarStart, srcStart, srcEnd)
	tarStart = tarStart or 0
	srcStart = srcStart or 0
	assert(tarStart >= 0 and srcStart >= 0, "Invalid argument!")

	srcEnd = srcEnd or self.size
	local len = srcEnd - srcStart
	len = math.min(len, self.size - srcStart, target.size - tarStart)
	if (len > 0) then
		ffi.copy(target.data + tarStart, self.data + srcStart, len)
	end
end

function Buffer:readUInt8(ofs, noAssert)
	if (noAssert) then
		assert(ofs >= 0 and ofs < self.size, "Invalid argument!")
		return self.data[ofs]
	else
		if (ofs>=0 and ofs<self.size) then
			return self.data[ofs]
		else
			return 0
		end
	end
end

local pint8 = ffi.typeof("int8_t*")
function Buffer:readInt8(ofs, noAssert)
	if (noAssert) then
		assert(ofs >= 0 and ofs < self.size, "Invalid argument!")
		return ffi.cast(pint8, self.data + ofs)[0]
	else
		if (ofs>=0 and ofs<self.size) then
			return ffi.cast(pint8, self.data + ofs)[0]
		else
			return 0
		end
	end
end

local puint16 = ffi.typeof("uint16_t*")
local function readUInt16LE(self, ofs, noAssert)
	if (noAssert) then
		assert(ofs >= 0 and ofs + 1 < self.size, "Invalid argument!")
		return ffi.cast(puint16, self.data + ofs)[0]
	else
		if (ofs>=0 and ofs + 1 < self.size) then
			return ffi.cast(puint16, self.data + ofs)[0]
		else
			return 0
		end
	end
end
Buffer.readUInt16LE = readUInt16LE

local function readUInt16BE(self, ofs, noAssert)
	local ret = readUInt16LE(self, ofs, noAssert)

	return bswap(lshift(ret, 16))
end
Buffer.readUInt16BE = readUInt16BE

local puint32 = ffi.typeof("uint32_t*")
local function readUInt32LE(self, ofs, noAssert)
	if (noAssert) then
		assert(ofs >= 0 and ofs + 3 < self.size, "Invalid argument!")
		return ffi.cast(puint32, self.data + ofs)[0]
	else
		if (ofs>=0 and ofs + 3 < self.size) then
			return ffi.cast(puint32, self.data + ofs)[0]
		else
			return 0
		end
	end
end
Buffer.readUInt32LE = readUInt32LE

local function readUInt32BE(self, ofs, noAssert)
	local ret = readUInt32LE(self, ofs, noAssert)

	return bswap(ret)
end

Buffer.readUInt32BE = readUInt32BE

local int16 = ffi.typeof("int16_t")
function Buffer:readInt16LE(ofs, noAssert)
	return tonumber(ffi.cast(int16, readUInt16LE(self, ofs, noAssert)))
end

function Buffer:readInt16BE(ofs, noAssert)
	return tonumber(ffi.cast(int16, readUInt16BE(self, ofs, noAssert)))
end

function Buffer:readInt32LE(ofs, noAssert)
	return tobit(readUInt32LE(self, ofs, noAssert))
end

function Buffer:readInt32BE(ofs, noAssert)
	return tobit(readUInt32BE(self, ofs, noAssert))
end

-- Big-endian achitecture support
if (ffi.abi("be")) then
	Buffer.readUInt16LE, Buffer.readUInt16BE = Buffer.readUInt16BE, Buffer.readUInt16LE
	Buffer.readUInt32LE, Buffer.readUInt32BE = Buffer.readUInt32BE, Buffer.readUInt32LE
	Buffer.readInt16LE, Buffer.readInt16BE = Buffer.readInt16BE, Buffer.readInt16LE
	Buffer.readInt32LE, Buffer.readInt32BE = Buffer.readInt32BE, Buffer.readInt32LE
end

function Buffer:toString(encoding, start, endpos)
	start = start or 0
	endpos = endpos or self.size
	return ffi.string(self.data + start, endpos - start)
end

bufferMT.__tostring = Buffer.toString

function bufferMT:__index(key)
	if (type(key) == 'number') then
		return self.data[key]
	else
		return Buffer[key]
	end
end

function bufferMT:__newindex(key, val)
	if (type(key) == 'number') then
		self.data[key] = val
	else
		error("Index must be a integer.")
	end
end

function bufferMT:__gc()
	if (self.data) then
		C.free(self.data)
	end
end

-- constructors 
local newBuffer = ffi.metatype(bufferCT, bufferMT)

local function newWithSize(sz)
	local self = newBuffer()
	if (sz > 0) then
		self.data = C.malloc(sz)
		self.size = sz
	else
		self.data = nil
		self.size = 0
	end
	return self
end

Buffer.newWithSize = newWithSize

local function newWithArray(arr)
	local self = newWithSize(#arr)
	for i=1, #arr do
		self.data[i-1] = arr[i]
	end
	return self
end

Buffer.newWithArray = newWithArray

local function newWithString(str, encoding)
	local self = newWithSize(#str)
	ffi.copy(self.data, str, #str)
	return self
end

Buffer.newWithString = newWithString

local function newWithBuffer(buf)
	local self = newWithSize(buf.size)
	ffi.copy(self.data, buf.data, buf.size)
	return self
end

Buffer.newWithBuffer = newWithBuffer

function Buffer.new(arg, ...)
	if (type(arg) == 'number') then
		return newWithSize(arg)
	elseif (type(arg) == 'string') then
		return newWithString(arg, ...)
	elseif (type(arg) == 'table') then
		return newWithArray(arg)
	elseif (ffi.istype(bufferCT, arg)) then
		return newWithBuffer(arg)
	else
		error("Invalid argument!")
	end
end

local function calcTotalSize(list)
	local size = 0
	for i = 1,#list do
		size = size + list[i].size
	end
	return size
end

function Buffer.concat(list, totalSize)
	totalSize = totalSize or calcTotalSize(list)
	local ret = newWithSize(totalSize)

	local offset = 0
	for i = 1, #list do
		offset = offset + writeBuffer(ret, list[i], offset)
	end
	return ret
end

function Buffer.isBuffer(buf)
	return ffi.istype(bufferCT, buf)
end

_G.Buffer = Buffer
return Buffer