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

Entity = class()

-- Entity is the root class for all "on table" objects
-- It has a position,angle,scale,second scale (if there is a second then they are for x and y),
-- a visibility flag (turned off when in a container for instance), and the methods to access them
-- (we need to encapsulate them for inheritance to work properly)

-- x,y,a can all be omitted and fall back to default values
function Entity:init(x,y,a)
	
	self.x = 0
	self.y = 0
	self.a = 0
	self.s = 1
	self.s2 = nil
	self.visible = true
	
	self:set(x,y,a)
	--self:scale(s,s2)
	
	return self
end

-- position and rotate the entity
-- each of x,y and a can be ommited and is left unchanged
function Entity:set(x,y,a)

	self.x = x or self.x
	self.y = y or self.y
	self.a = a or self.a
	
	return self
end

-- scale the entity
-- must be given either one argument (uniform scale), or two non nil (for each axis)
-- (if first argument is nil, scale is reinitialized to uniform 1)
function Entity:scale(s,s2)
	
	if s == nil then
		self.s = 1
		self.s2 = nil
	else
		self.s = s
		self.s2 = s2
	end

	return self
end

-- if the boolean flag is given, sets visibility to it.
-- return visibility in any case
function Entity:setvisible(flag)
	if flag == true then
		self.visible = true
	elseif flag == false then
		self.visible = false
	end
	
	-- (if it's nil, do nothing)
	
	return self.visible
end

-- is used by the server when someone connects
-- (later for savegames?)
-- should be overloaded, of course
function Entity:dumpstatus(nick, id)

	return FMT("ENTITY %s %d %d %d %d", nick, id, self.x, self.y, self.a)
end
