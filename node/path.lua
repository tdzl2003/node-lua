-- NOTICE:
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
-- POSSIBILITY OF SUCH DAMAGE.
-- 
-- read LICENSE.md for more informations.

local path = {}
rawset(_G, "path", path)

local curdir = "."
local pardir = ".."
local sep = "/"
local isWindows

do
    local ffi = require("ffi")
    local C = ffi.C

    if (jit.os=="Windows") then
        isWindows = true
        -- Win32 implements.

        ffi.cdef[[
            void* malloc(size_t size);
            void free(void* data);
            char* _getcwd(char* buffer, int maxlen);
        ]]

        function path.current()
            local buff = C.malloc(256)
            local ret = ffi.string(C._getcwd(buff, 256))
            C.free(buff)
            return ret
        end
    else
        -- POSIX implements.

        ffi.cdef[[
            void* malloc(size_t size);
            void free(void* data);
            char* getcwd(char* buffer, int maxlen);
        ]]

        function path.current()
            local buff = C.malloc(256)
            local ret = ffi.string(C.getcwd(buff, 256))
            C.free(buff)
            return ret
        end
    end
end

local current = path.current

if (isWindows) then
    sep = "\\"
    function path.isabs(str)
        return str:find("%a%:") == 1 or str:find("[%/%\\]") == 1
    end
    
    function path.splitdrive(str)
        if (str:sub(2, 2) == ':') then
            return str:sub(1, 2), str:sub(3)
        end
        return '', str
    end

    assert(path.isabs(current()))
    assert(path.isabs("c:\\index.html"))
    assert(path.isabs("h:"))
    assert(path.isabs("/test/"))
    assert(not path.isabs("test"))
    
else
    function path.splitdrive(str)
        return '', str
    end
    function path.isabs(str)
        return str:find("%/") == 1
    end

    assert(path.isabs(current))
    assert(path.isabs("/usr/home"))
    assert(not path.isabs(".src"))
    assert(not path.isabs("ppp/asdf/asdf"))
end

path.sep = sep
local isabs = path.isabs
local splitdrive = path.splitdrive

function path.join(...)
    local t={...}
    local p="."
    for i,v in ipairs(t) do
        if (isabs(v)) then
            p = v
        else
            p = p .. sep .. v
        end
    end
    return p
end
local join = path.join

function path.normalize(path, sep)
    local orgpath = path
    
    if (path == "") then
        return '.'
    end
    
    if (isWindows and path:find("%\\%\\[^%/%\\]+%\\") ==1) then
        return path
    end
    
    local prefix = ""
    
    if (isWindows) then
        --split drive sign
        local p1, p2 = path:match("(%a%:)(.+)")
        if (p1) then
            prefix = p1
            path = p2
            if (path:find("[%/%\\]") == 1) then
                prefix = prefix .. "\\"
                local i = path:find("[^%/%\\]")
                if (i) then
                    path = path:sub(i)
                else
                    path = ""
                end
            end
        else
            while(path:find("[%/%\\]") == 1) do
                prefix = prefix .. path:sub(1, 1)
                path = path:sub(2)
            end
        end
    else
		if (path:find("[%/%\\]") == 1) then
			prefix = path:sub(1, 1)
			path = path:sub(2)
		end
    end
    local comps = {}

    for k in path:gmatch("[^%/%\\]+") do
        table.insert(comps, k)
    end
    local outt = {}
    local j = 0
    for i=1, #comps do
        if (comps[i] =='.' or comps[i] == '') then
        elseif (comps[i] == '..') then
            if (j > 0 and outt[j] ~= "..") then
                outt[j] = nil
                j = j-1
            elseif (j == 0 and prefix~= "") then
            else
                j = j+1
                outt[j] = comps[i]
            end
        else
            j = j+1
            outt[j] = comps[i]
        end
    end
    if (prefix=='' and j == 0) then
        return '.'
    end
    if (isWindows) then
		sep = sep or '\\'
    else
		sep = sep or '/'
    end
    return prefix .. table.concat(outt, sep)
end
local normalize = path.normalize

function path.split(p)
    for i=#p,1,-1 do
        if (p:sub(i, i):match("[%/%\\]")) then
            local j = i;
            while (p:sub(j, j):match("[%/%\\]")) do
                j = j - 1
                if (j == 0) then
                    j = i
                    break;
                end
            end
            return p:sub(1, j), p:sub(i+1)
        end
    end
    return "", p
end
local split = path.split
function path.splitext(p)
    for i=#p-1,1,-1 do
        if (p:sub(i, i):match("%.")) then
            return p:sub(1, i-1), p:sub(i)
        end
        if (p:sub(i, i):match("[%/%\\]")) then
			return p, ''
        end
    end
    return p, ''
end

function path.basename(p)
    local b, t = split(p)
    return t
end

function path.dirname(p)
    local b, t = split(p)
    return b
end

function path.normjoin(...)
    return normalize(join(...))
end

function path.abspath(path)
    return normalize(join(current, path))
end

local function _abspath_split(path)
    path = abspath(path)
    local prefix, rest = splitdrive(path)
    return prefix, rest:split("[%/%\\]", false, true)
end

function path.relpath(path, start)
    start = start or current
    
    local start_prefix, start_list = _abspath_split(start)
    local path_prefix, path_list = _abspath_split(path)
    
    if (start_prefix:lower() ~= path_prefix:lower()) then
        return path
    end
    
    i = 1
    while (i<=#start_list and i<=#path_list and start_list[i] == path_list[i]) do
        i = i + 1
    end
    
    local rel_list = {}
    for j = i, #start_list do
        table.insert(rel_list, pardir)
    end
    for j = i, #path_list do
        table.insert(rel_list, path_list[j])
    end
    if (#path_list == 0) then
        return '.'
    end
    return table.concat(rel_list, sep)
end

--[[
function path.isdir(path)
    return fbmakelib.isdir(path)
end

function path.isfile(path)
    return fbmakelib.isfile(path)
end

function path.exist(path)
    return fbmakelib.exist(path)
end

function path.modifiedTime(path)
	return fbmakelib.modifiedTime(path)
end

function createdTime(path)
	return fbmakelib.createdTime(path)
end

function listfile(...)
	return fbmakelib.listfile(...)
end

function listsubdir(...)
	return fbmakelib.listsubdir(...)
end

function mkdir(path, mode) --mode = 777
    mode = mode or 0x1FF
    local head, tail = split(path)
    if (tail == "") then
        head, tail = split(head)
    end
    if (head~="" and tail~="" and not exist(head)) then
        mkdir(head, mode)
    end
    if (not exist(path)) then
        fbmakelib.mkdir(path, mode)
    end
end

function rmdir(path, func)
	for i,v in ipairs(listfile(path)) do
		local p = normjoin(path, v)
		if func then
			func(p)
		end
		os.remove(p)
	end
	for i,v in ipairs(listsubdir(path)) do
		rmdir(join(path, v))
	end
	
	local p = normpath(path)
	if func then
		func(p)
	end
	
	if (isWindows) then
		os.execute("rmdir ".. p)
	else
		os.remove(p)
	end
end
]]

return path