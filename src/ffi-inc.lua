local ffi = require("ffi")

if (ffi.include ~= nil) then
	return nil
end

if (ffi.headers == nil) then
	ffi.headers = {}
end
if (ffi.const == nil) then
	ffi.const = {}
end

ffi.include = function(h, search)
	local inc = '-I.'
	if (search) then
		for i,path in pairs(search) do
			inc = inc .. " -I'"..path.."'"
		end
	end
	--print("include", h)
	local f,err = io.popen("echo -ne '#include <" .. h .. ">\n' | gcc " .. inc .. " -E -")
	if (f) then
		local cur_h
		local ordered = {};
		local files   = {}
		while true do
			local line = f:read()
			if line then
				if line:match("^%s*$") then
				else
					local file = line:match('^#%s+%d+%s+"([^"]+)"')
					if ( file ~= nil ) then
						if not file:match('^<.+>$') then
							cur_h = file
						else
							cur_h = nil
						end
					elseif line:match('^#') then
						error("unmatched line",line)
					else
						if (cur_h) then
							table.insert(ordered, { cur_h; line } )
						end
					end
				end
			else
				break
			end
		end
		
		local source = {}
		local newh = {}
		for x,pair in pairs(ordered) do
			local h,line = unpack(pair)
			
			if (ffi.headers[h] == nil) then
				table.insert(source,line);
				newh[h] = true
			else
				-- print("header <"..h.."> already loaded")
			end
		end
		if (#source > 0) then
			local src = table.concat(source, "\n")
			local r,e = pcall(ffi.cdef,src)
			if (r) then
			else
				print(src)
				error("Error loading ["..x.."] "..h..": "..e)
			end
		end
		for h,x in pairs(newh) do
			--print("included",h)
			ffi.headers[h] = x
		end
	else
		error(err)
	end
end

local gensym = 0

ffi.constants = function(headers,what,search)
	local inc = '-I.'
	local includes = ''
	local x,h
	for x,h in pairs(headers) do
		includes = includes .. '#include <' .. h .. '>\\n'
	end
	--print(includes)
	if (search) then
		local path
		for x,path in pairs(search) do
			inc = inc .. " -I'"..path.."'"
		end
	end
	local count = 0
	local map = {}
	local defines = 'enum {'
	for x,h in pairs(what) do
		--if (ffi.const[h] == nil) then
			if (count > 0) then defines = defines .. ',' end
			count = count + 1
			gensym = gensym + 1
			map[ gensym ] = h
			defines = defines .. '__FFI_DEF__'..gensym..'='..h..'\\n'
		--end
	end
	defines = defines .. '};\\n'
	if (count == 0) then return end
	--print(defines)
	local f,err = io.popen("echo -ne '"..includes..defines.."' | gcc " .. inc .. " -E -")
	if (f) then
		local take = false
		local lines = {}
		while true do
			local line = f:read()
			if line then
				if line:match("^%s*$") then
				else
					local file = line:match('^#%s+%d+%s+"([^"]+)"')
					if ( file ~= nil ) then
						if file:match('^<stdin>$') then
							take = true
						else
							take = false
						end
					elseif line:match('^#') then
						error("unmatched line",line)
					else
						if (take) then
							table.insert(lines,line)
							-- table.insert(ordered, { cur_h; line } )
						end
					end
				end
			else
				break
			end
		end
		ffi.cdef(table.concat(lines,"\n"))
		local k,c
		for k,c in pairs(map) do
			local value = ffi.C['__FFI_DEF__'..k]
			if (ffi.const[c] == nil) then
				ffi.const[c] = value
			else
				if (ffi.const[c] ~= value) then
					error("Constant "..c.." redefined from "..ffi.const[c].." to "..value)
				end
			end
		end
	else
		error(err)
	end

end

return nil
