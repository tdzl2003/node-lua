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

-- register package path for fbmake modules
local scriptroot

do
	-- use path lib locally
	local path = dofile(arg[0]:match("(.+[\\/])%w+%.lua").."path.lua")

	scriptroot = path.dirname(path.normalize(arg[0]))
	
	--register package path
	package.path = package.path..path.join(scriptroot,"?.lua")..";"..path.join(scriptroot, "?.luac")..";"
end

local path = require("path")

require("lua_ex")

-- TODO: use option module to parse command line.
dofile(arg[1])

local uv = require("uv")
local uv_lua = require("uv_lua")
uv_lua.uv_run(uv.uv_default_loop(), uv.UV_RUN_DEFAULT)
