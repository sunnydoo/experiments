
-- comment out this line to remove weakness
local mt = { __mode = "kv"}

local tbl = { "host" }
setmetatable( tbl, mt )

do
	local ele = {"element" }
	tbl[ ele ] = ele
	
end

collectgarbage()

for k,v in pairs(tbl) do

	print(k, v)
	
end