local fv = getfenv()

for k,v in pairs( fv ) do
    print( k .. " with v: " .. type( v ) )
end 