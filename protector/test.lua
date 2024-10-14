function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

local function getPath(str)
    return str:match("(.*\\)")
end

print(getPath(arg[0]))

print(file_exists('main.lua'))
print(file_exists('protector/main.lua'))