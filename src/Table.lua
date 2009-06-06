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

local LG = love.graphics

love.filesystem.require("common/class.lua")

Table = class()

-- The Client table is adapted from the server one, with added drawing stuff

function Table:init()
	
	self.ids = {}	-- entities, indexed by numerical identifier
	self.last = 0	-- used to keep track of the biggest id in the table
	
	self.x = 0	-- camera position: these coords are drawn at the center
	self.y = 0	-- of the screen
	self.zoom = 1
	self.zoomtarget = 1

	self.dragged = false	-- dragging stuff
	self.dragx = nil
	self.dragy = nil
	
	return self
end

-- adds to the table an entity already created with identifier id
-- returns the entity index and the entity
function Table:add(id,e)
	
	if id > self.last then
		self.last = id
	end
	
	self.ids[id] = e

	return self
end

-- remove the entity number id
function Table:remove(id)
	
	self.ids[id] = nil
	
	return self
end

-- an iterator factory to go over all entities, but in order (which is not assured by pairs()
-- and ipairs() stops at the first nil)
function Table:pairs()
	local i = 0
	return function()
		
		-- find the next non nil element
		repeat
			i = i + 1
		until self.ids[i] ~= nil or i > self.last
		
		-- return it 
		if self.ids[i] then
			return i, self.ids[i]
		end
		
		-- (or nil if we existed the loop because of the second condition)
	end
end

function Table:draw()
	
	-- simply draw the things in order
	for id,e in self:pairs() do
		e:draw()
	end
end

-- coordinate spaces convertion
function Table:game2screen(x,y)

	local x = (x - self.x)*self.zoom + LG.getWidth()/2
	local y = (y - self.y)*self.zoom + LG.getHeight()/2
	
	return x,y
end

function Table:screen2game(x,y)

	local x = (x - LG.getWidth()/2) / self.zoom + self.x
	local y = (y - LG.getHeight()/2) / self.zoom + self.y
	
	return x,y
end

-- event handling

function Table:mousepressed(x,y,button)
	
	-- later, we will check if it's not an entity that is dragged, first
	
	-- drag the table
	if button == 1 then
		self.dragged = true
		self.dragx = x
		self.dragy = y
		
	-- zoom the table around the mouse	
	elseif button == 4 then
		self.zoomtarget = self.zoomtarget + 0.1

	elseif button == 5 then
		if self.zoomtarget > 0.2 then 
			self.zoomtarget = self.zoomtarget - 0.1
		end
	end
end

function Table:mousereleased(x,y,button)

	if button == 1 then
		self.dragged = false
	end
end

function Table:update(dt)
	
	-- the smooth zoom
	local dzoom = (self.zoomtarget - self.zoom)*5*dt
	self:incrzoom(dzoom)
	
	-- dragging the table
	
	if self.dragged then
		local x,y = love.mouse.getX(), love.mouse.getY()
		self.x = self.x - (x - self.dragx)/self.zoom
		self.y = self.y - (y - self.dragy)/self.zoom
		
		self.dragx = x
		self.dragy = y		
	end

end

-- this makes the zooming occur around the mouse
-- formulas were a pain to find, but basically
-- if s the mouse, and p the corresponding game point,
--	s = g2s(p) before and s = g2s(p) after
-- since in the formula, zoom changes, so must self.xy
function Table:incrzoom(dz)
	
	if dz == 0 then return end

	local x,y = self:screen2game(love.mouse.getX(), love.mouse.getY())
	local fact = self.zoom / (self.zoom + dz)
	
	self.x = x * (1 - fact) + self.x*fact
	self.y = y * (1 - fact) + self.y*fact
	
	self.zoom = self.zoom + dz
end
