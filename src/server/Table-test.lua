package.path = package.path .. ";../common/?.lua"

require "Table"

a = Table()

for i = 1,10 do
	a:add(i)
end

a:remove(3)
a:remove(6)

for i,e in a:pairs() do
	print(i,e)
end
