-- pöytä
-- Copyright (C) 2009 Noé Falzon <firstname.lastname@aliceadsl.fr>

-- This program is  free software:  you can redistribute it and/or modify it
-- under  the terms  of the  GNU General Public License  as published by the
-- Free Software Foundation, version 3 of the License.
--
-- This program  is  distributed  in the hope  that it will  be useful,  but
-- WITHOUT  ANY WARRANTY;  without  even the implied  warranty of MERCHANTA-
-- BILITY  or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
-- License for more details.
--
-- You should have received a copy of the  GNU General Public License  along
-- with this program. If not, see <http://www.gnu.org/licenses/>.

love.filesystem.require("common/class.lua")

EventHandler = class()

-- The EventHandler forwards the events to the objects that registered to it, on the form

-- {type,...}
-- where type is on the following: "mdown", "mup", "kdown", "kup", and ... the additional
-- arguments given by Löve's callbacks.
-- The order of registering gives the order of forwarding.

-- The objects should answer to the message treatevent() and return the event, either unchanged,
-- or changed, or nil, in which case the forwarding stops
-- The objects can alternatively implement :[key/mouse][pressed/released]() similar to the usual
-- Löve callbacks. They can return they arguments modified or not, that will be forwarded, or nil
-- to intercept the event.

-- it also keeps track of the hot element, by sending the registered object the message ishot()
-- which should return either nil or a pointer to an object.

function EventHandler:init()
	
	self.reg = {}	-- table of objects to which forward the events
	
	self.hot = nil	-- any object that has the cursor on it at a given time
			-- later they might have to answer to methods such as "dropOn" and so on

	return self
end

function EventHandler:register(obj)
	
	table.insert(self.reg, obj)
	
	return obj
end

function EventHandler:update(dt)

	-- keep track of the hot object, by order of priority
	local x,y = love.mouse.getX(),love.mouse.getY()
	self.hot = nil
	
		--first the console
	if Console:isinside(x,y) then
		self.hot = Console
		
		--then the hot entity on the table, if any
	elseif Table.hot then
		self.hot = Table.hot
	end

end

function EventHandler:treatevent(e)
	local func = nil

	if e[1] == "kdown" then
		func = "keypressed"
	elseif e[2] == "kup" then
		func = "keyreleased"
	elseif e[2] == "mdown" then
		func = "mousepressed"
	elseif e[2] == "mup" then
		func = "mousereleased"
	end
	
	if not func then return end
	
	for i,v in ipairs(self.reg) do
		local e = e
		if v.treatevent then
			e = v.treatevent(e)
		elseif v[func] then
			e[2],e[3],e[4] = v[func](v,e[2],e[3],e[4])	-- calls v:func(...)
		end
		
		if not e or not e[2] then break end
	end
	
end

-- a table of totally priority events

GlobalEvents = {}
function GlobalEvents:keypressed(key)
	
	-- intercept these events
	
	if key == love.key_escape then
		love.system.exit()
		return
	elseif key == love.key_f1 then
		love.system.restart()
		return
	end
	
	-- forward the others
	
	return key
end

-- plugging things with Löve's callbacks

function keypressed(key)
	EventHandler:treatevent{"kdown",key}
end

function keyreleased(key)
	EventHandler:treatevent{"kup",key}
end

function mousepressed(x,y,button)
	EventHandler:treatevent{"mdown",x,y,button}
end

function mousereleased(x,y,button)
	EventHandler:treatevent{"mup",x,y,button}
end
