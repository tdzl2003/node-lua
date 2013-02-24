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
	if (not noAssert) then
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
	if (not noAssert) then
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
	if (not noAssert) then
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
	if (not noAssert) then
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

function Buffer:readUInt32BE(ofs, noAssert)
	local r = readUInt32LE(self, ofs, noAssert)
	r = ffi.cast("unsigned int", bswap(r))
	return r
end

local int16 = ffi.typeof("int16_t")
function Buffer:readInt16LE(ofs, noAssert)
	return ffi.cast(int16, readUInt16LE(self, ofs, noAssert))
end

function Buffer:readInt16BE(ofs, noAssert)
	return ffi.cast(int16, readUInt16BE(self, ofs, noAssert))
end

function Buffer:readInt32LE(ofs, noAssert)
	return tobit(readUInt32LE(self, ofs, noAssert))
end

function Buffer:readInt32BE(ofs, noAssert)
	return tobit(readUInt32BE(self, ofs, noAssert))
end

--read a float from buffer
local pfloat  = ffi.typeof("float*")
local float32 = ffi.typeof("float")
local function readFloatLE(self, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+3<self.size, "Invalid argument!")
		return ffi.cast(pfloat, self.data+ofs)[0]
	else
		if (ofs>=0 and ofs+3<self.size) then
			return ffi.cast(pfloat, self.data+ofs)[0]
		else
			return 0
		end
	end
end
Buffer.readFloatLE = readFloatLE

local function readFloatBE(self, ofs, noAssert)
	return (floatBSwap(readFloatLE(self, ofs, noAssert)))
end
Buffer.readFloatBE = readFloatBE

--read a double from buffer
local pdouble  = ffi.typeof("double*")
local double64 = ffi.typeof("double")
local function readDoubleLE(self, ofs, noAssert)
	if (not noAssert) then 
		assert(ofs>=0 and ofs+7<self.size, "Invalid argument!")
		return ffi.cast(pdouble, self.data+ofs)[0]
	else
		if (ofs>=0 and ofs+7<self.size) then
			return ffi.cast(pdouble, self.data+ofs)[0]
		else
			return 0
		end
	end
end
Buffer.readDoubleLE = readDoubleLE

local function readDoubleBE(self, ofs, noAssert)
	return doubleBSwap(readDoubleLE(self, ofs, noAssert))
end
Buffer.readDoubleBE = readDoubleBE

local pint64 = ffi.typeof("long long*")
local int64  = ffi.typeof("long long")
local function readInt64LE(self, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+7<self.size, "Invalid argument!")
		return ffi.cast(pint64, self.data+ofs)[0]
	else
		if (ofs>=0 and ofs+7<self.size) then
			return ffi.cast(pint64, self.data+ofs)[0]
		else
			return 0
		end
	end
end
Buffer.readInt64LE = readInt64LE

local function readInt64BE(self, ofs, noAssert)
	return int64BSwap(readInt64LE(self, ofs, noAssert))
end
Buffer.readInt64BE = readInt64BE

local puint64 = ffi.typeof("unsigned long long*")
local uint64  = ffi.typeof("unsigned long long")
local function readUInt64LE(self, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+7<self.size, "Invalid argument!")
		return ffi.cast(puint64, self.data+ofs)[0]
	else
		if (ofs>=0 and ofs+7<self.size) then
			return ffi.cast(puint64, self.data+ofs)[0]
		else
			return 0
		end
	end
end
Buffer.readUInt64LE = readUInt64LE

local function readUInt64BE(self, ofs, noAssert)
	local r = readUInt64LE(self, ofs, noAssert)
	r = int64BSwap(r)
	r = ffi.cast(uint64, r)
	return r
end
Buffer.readUInt64BE = readUInt64BE

local function writeUInt8(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+1<self.size, "Invalid argument!")
		self.data[ofs] = value
	else
		if (ofs>=0 and ofs+1<self.size) then
			local p = ffi.cast(pint8, self.data+ofs)
			self.data[ofs] = value
		end
	end
end
Buffer.writeUInt8 = writeUInt8

local function writeUInt16LE(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+2<self.size, "Invalid argument!")
		local p = ffi.cast(puint16, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+2<self.size) then
			local p = ffi.cast(puint16, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeUInt16LE = writeUInt16LE

local function writeUInt16BE(self, value, ofs, noAssert)
	local v = bswap(lshift(value, 16))
	writeUInt16LE(self, v, ofs, noAssert)
end
Buffer.writeUInt16BE = writeUInt16BE

local function writeUInt32LE(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+4<self.size, "Invalid argument!")
		local p = ffi.cast(puint32, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+4<self.size) then
			local p = ffi.cast(puint32, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeUInt32LE = writeUInt32LE

local function writeUInt32BE(self, value, offset, noAssert)
	local v = bswap(value)
	writeUInt32LE(self, v, offset, noAssert)
end
Buffer.writeUInt32BE = writeUInt32BE

local function writeInt8(self, value, offset, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+1<self.size, "Invalid argument!")
		local p = ffi.cast(pint8, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+1<self.size) then
			local p = ffi.cast(pint8, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeInt8 = writeInt8

local pint16 = ffi.typeof("int16_t*")
local function writeInt16LE(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+2<self.size, "Invalid argument!")
		local p = ffi.cast(pint16, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+2<self.size) then
			local p = ffi.cast(pint16, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeInt16LE = writeInt16LE

local function writeInt16BE(self, value, ofs, noAssert)
	local v = bswap(lshift(value, 16))
	writeUInt16LE(self, v, ofs, noAssert)
end
Buffer.writeInt16BE = writeInt16BE

local pint32 = ffi.typeof("int*")
local function writeInt32LE(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+4<self.size, "Invalid argument!")
		local p = ffi.cast(pint32, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+4<self.size) then
			local p = ffi.cast(pint32, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeInt32LE = writeInt32LE

local function writeInt32BE(self, value, ofs, noAssert)
	local v = bswap(value)
	writeInt32LE(self, v, ofs, noAssert)
end
Buffer.writeInt32BE = writeInt32BE

local function writeFloatLE(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+4<self.size, "Invalid argument!")
		local p = ffi.cast(pfloat, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+4<self.size) then
			local p = ffi.cast(pfloat, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeFloatLE = writeFloatLE

local function writeFloatBE(self, value, ofs, noAssert)
	local v = floatBSwap(value)
	writeFloatLE(self, v, ofs, noAssert)
end
Buffer.writeFloatBE = writeFloatBE

local function writeDoubleLE(self, value, ofs ,noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+8<self.size, "Invalid argument!")
		local p = ffi.cast(pdouble, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+8<self.size) then
			local p = ffi.cast(pdouble, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeDoubleLE = writeDoubleLE

local function writeDoubleBE(self, value, ofs, noAssert)
	local v = doubleBSwap(value)
	writeDoubleLE(self, v, ofs, noAssert)
end
Buffer.writeDoubleBE = writeDoubleBE

local function writeInt64LE(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+8<self.size, "Invalid argument!")
		local p = ffi.cast(pint64, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+8<self.size) then
			local p = ffi.cast(pint64, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeInt64LE = writeInt64LE

local function writeInt64BE(self, value, ofs, noAssert)
	local v = int64BSwap(value)
	writeInt64LE(self, v, ofs, noAssert)
end
Buffer.writeInt64BE = writeInt64BE

local function writeUInt64LE(self, value, ofs, noAssert)
	if (not noAssert) then
		assert(ofs>=0 and ofs+8<self.size, "Invalid argument!")
		local p = ffi.cast(puint64, self.data+ofs)
		p[0] = value
	else
		if (ofs>=0 and ofs+8<self.size) then
			local p = ffi.cast(puint64, self.data+ofs)
			p[0] = value
		end
	end
end
Buffer.writeUInt64LE = writeUInt64LE

local function writeUInt64BE(self, value, ofs, noAssert)
	value = ffi.cast("unsigned long long",value)
	local v = int64BSwap(value)
	writeUInt64LE(self, v, ofs, noAssert)
end
Buffer.writeUInt64BE = writeUInt64BE

-- Big-endian achitecture support
if (ffi.abi("be")) then
	Buffer.readUInt16LE, Buffer.readUInt16BE = Buffer.readUInt16BE, Buffer.readUInt16LE
	Buffer.readUInt32LE, Buffer.readUInt32BE = Buffer.readUInt32BE, Buffer.readUInt32LE
	Buffer.readUInt64LE, Buffer.readUInt64BE = Buffer.readUInt64BE, Buffer.readUInt64LE

	Buffer.readInt16LE, Buffer.readInt16BE = Buffer.readInt16BE, Buffer.readInt16LE
	Buffer.readInt32LE, Buffer.readInt32BE = Buffer.readInt32BE, Buffer.readInt32LE
	Buffer.readInt64LE, Buffer.readInt64BE = Buffer.readInt64BE, Buffer.readInt64LE

	Buffer.readFloatLE,  Buffer.readFloatBE  = Buffer.readFloatBE, Buffer.readFloatLE
	Buffer.readDoubleLE, Buffer.readDoubleBE = Buffer.readDoubleBE, Buffer.readDoubleLE

	Buffer.writeUInt16LE, Buffer.writeUInt16BE = Buffer.writeUInt16BE, Buffer.writeUInt16LE
	Buffer.writeUInt32LE, Buffer.writeUInt32BE = Buffer.writeUInt32BE, Buffer.writeUInt32LE
	Buffer.writeUInt64LE, Buffer.writeUInt64BE = Buffer.writeUInt64BE, Buffer.writeUInt64LE

	Buffer.writeInt16LE, Buffer.writeInt16BE = Buffer.writeInt16BE, Buffer.writeInt16LE
	Buffer.writeInt32LE, Buffer.writeInt32BE = Buffer.writeInt32BE, Buffer.writeInt32LE
	Buffer.writeInt64LE, Buffer.writeInt64BE = Buffer.writeInt64BE, Buffer.writeInt64LE

	Buffer.writeFloatLE,  Buffer.writeFloatBE  = Buffer.writeFloatBE,  Buffer.writeFloatLE
	Buffer.writeDoubleLE, Buffer.writeDoubleBE = Buffer.writeDoubleBE, Buffer.writeDoubleLE	
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

rawset(_G,  "Buffer",  Buffer)
return Buffer