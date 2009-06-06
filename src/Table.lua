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

function Table:update()

end

function Table:draw()
	
	-- simply draw the things in order
	for id,e in self:pairs() do
		e:draw()
	end
end
