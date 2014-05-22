--Lua script call the APIs exported from C/C++ dll. 
local mylib = package.loadlib("myluadll.dll", "luaopen_mylib")
functbl = mylib()

--print out the APIs exported by our C DLL
print("The APIs exported by our C dll are:")
for v in pairs(functbl) do
    print(v)
end

functbl.hello()
a = math.rad(30)
print("mysin(30) = "..functbl.mysin(a))
print("math.sin(30) = "..math.sin(a))



