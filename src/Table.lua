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
				
	self.sprite = LG.newImage("background.png")
	
	return self
end

-- adds to the table an entity already created with identifier id
-- returns the entity index and the entity
function Table:add(id,e)
	
	if id > self.last then
		self.last = id
	end
	
	self.ids[id] = e

	-- also give the entity its id, for easier conversion
	e.id = id

	return self
end

-- special insertion that moves up num elements to make room
-- here we trust server about this num, because it knows more than us

function Table:insert(e,pos,num)

	-- move them up (start with the top
	-- to avoid losing data)
	for i = pos + num - 1,pos,-1 do
		local elem = self.ids[i]
		if elem then
			self.ids[i+1] = elem
			elem.id = i+1
		end
	end
	
	-- now that we've made room, take the place
	self.ids[pos] = e
	e.id = pos
end

-- remove the entity number id
function Table:remove(id)
	
	self.ids[id] = nil
	
	return self
end

-- an iterator factory to go over all entities, but in order (which is not assured by pairs(),
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

-- returns the next non nil element after position pos
-- or nil if there is none
-- step can be set to -1 to go backwards
function Table:next(pos,step)
	local i = pos
	local step = step or 1
	
	-- find the next non nil element
	repeat
		i = i + step
	until self.ids[i] ~= nil or i > self.last or i < 0
	
	-- return it 
	if self.ids[i] then
		return i, self.ids[i]
	end
end

function Table:draw()
	
	-- background
	local x,y = self:game2screen(0,0)
	LG.draw(self.sprite,x,y,0,self.zoom)
	
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
		
	-- first forward event to entities
	for id,e in self:pairs() do
		e:mousepressed(x,y,button)
	end

	-- Left click
	if button == love.mouse_left then
		-- if no hot entity, or the hot one is locked to the table, start dragging the table
		if not EventHandler.hot or EventHandler.hot.locked then	
			self.dragged = true
			self.dragx = x
			self.dragy = y
		end
	
	-- Wheel up and down: zoom the table around the mouse	
	elseif button == love.mouse_wheelup then
		self.zoomtarget = self.zoomtarget + 0.1

	elseif button == love.mouse_wheeldown then
		if self.zoomtarget > 0.2 then 
			self.zoomtarget = self.zoomtarget - 0.1
		end
	end
	
	return nil	-- in any case, intercept the event
end

function Table:mousereleased(x,y,button)

	-- forward to entities first
	for id,e in self:pairs() do
		e:mousereleased(x,y,button)
	end
	
	-- if we were dragging the table, stop
	if button == love.mouse_left and self.dragged then
		self.dragged = false
	end
	
	return nil	-- in any case, intercept the event
end

-- return (to EventHandler) the object in which the pointer is, if any
function Table:isinside(x,y)

	-- checking hotness of entities
	local x,y = self:screen2game(x,y)
	local hot = nil

	for id,e in self:pairs() do
		if e:isinside(x,y) then
			hot = e		-- this will keep only the top one hot
		end
	end
	
	return hot
end

function Table:update(dt)
	
	-- update entities
	for id,e in self:pairs() do
		e:update(dt)
	end
	
	-- the smooth zoom
	local zoomdiff = self.zoomtarget - self.zoom
	local dzoom = zoomdiff*5*dt
	if math.abs(dzoom) > math.abs(zoomdiff) then 	-- avoid passing over the target and jumping around it
		dzoom = zoomdiff
	end
	self:incrzoom(dzoom)
	
	
	-- dragging the table
	if self.dragged then
		local x,y = love.mouse.getX(), love.mouse.getY()
		
		local shiftx = (x - self.dragx)/self.zoom
		local shifty = (y - self.dragy)/self.zoom
	
		self.x = self.x - shiftx
		self.y = self.y - shifty
		
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
