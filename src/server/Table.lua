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

require "class"

Table = class()

function Table:init()
	
	self.ids = {}	-- entities, indexed by numerical identifier
	self.last = 0	-- used to give unique identifiers to new entities
	
	return self
end

-- adds to the table an entity already created
-- returns the entity index and the entity
function Table:add(e)
	
	self.last = self.last + 1
	self.ids[self.last] = e
	
	return self.last, e
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
