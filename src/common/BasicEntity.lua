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

require "Entity"

-- BasicEntity is just a "virtual" class from which derive, well, the basic entities.
-- It doesn't do much.

BasicEntity = class(Entity)

-- this has to be overloaded...
function BasicEntity:compare(other)

	-- all BasicEntities are the same, so...
	return other.class == BasicEntity
end



-------------------------------------------------------------
--[[ N-Image ]]----------------------------------------------
-------------------------------------------------------------

NImage = class(BasicEntity)

function NImage:init(x,y,a, ...)

	-- init as an Entity
	NImage.super.init(self,x,y,a)
	
	-- the sprite names
	self.sprites = {}
	for i,v in ipairs{...} do
		if type(v) == "string" then
			table.insert(self.sprites, v)
		end
	end
	
	if #self.sprites < 1 then
		self.sprites[1] = "dummy"
	end
	
	-- the current top sprite (an index)
	self.curr = 1
		
	-- modulating color
	self.r = 255
	self.g = 255
	self.b = 255
	
	return self	
end

function NImage:setcolor(r,g,b)
	
	self.r = r or 255
	self.g = g or 255
	self.b = b or 255
	
	-- keep values in boundaries
	if self.r < 0 then self.r = 0 end
	if self.g < 0 then self.g = 0 end
	if self.b < 0 then self.b = 0 end
	
	if self.r > 255 then self.r = 255 end
	if self.g > 255 then self.g = 255 end
	if self.b > 255 then self.b = 255 end
end

function NImage:compare(other)

	if other.class ~= NImage or self.r ~= other.r or self.g ~= other.g or self.b ~= other.b or #self.sprites ~= #other.sprites then
		return false
	end
	
	for i,v in ipairs(self.sprites) do
		if v ~= other.sprites[i] then
			return false
		end
	end
	
	return true
end

-- flips to the next image, or a random one if random is true
function NImage:flip(random)
	
	if random then
		self.curr = math.random(1,#self.sprites)
	else
		self.curr = self.curr % #self.sprites + 1	-- indexing from 1 is weird with mod math
	end
end

-- overload parent's one
function NImage:dumpstatus(nick, id)
	
	local str = FMT("IMAGE %s %d %d %d %d %d ", nick, id, self.x, self.y, self.a, #self.sprites)
	
	for i,v in ipairs(self.sprites) do
		str = str .. v .. " "
	end
	
	str = str .. FMT("%d %d %d %d", self.curr, self.r, self.g, self.b)
	return str
end


-------------------------------------------------------------
--[[ Label ]]------------------------------------------------
-------------------------------------------------------------

Label = class(BasicEntity)

function Label:init(x,y,a,text,text2,id)

	-- init as an Entity
	Label.super.init(self,x,y,a)
	
	-- add text
	self.text = {
		text,
		text2,
	}
	
	self.curr = 1
	
	-- attach to entity
	if id then
		self.attach = id
	end

	return self
end

function Label:compare(other)
	
	return self.text[1] == other.text[1] and self.text[2] == other.text[2]
end

-- flips to the other side, or to a random one if random is true
function Label:flip(random)
	
	if random then
		self.curr = math.random(1,2)
	else
		self.curr = self.curr % 2 + 1	-- indexing from 1 is weird with mod math
	end
end

-- overload parent's one
function Label:dumpstatus(nick, id)
	
	local str = FMT("LABEL %s %d %d %d %d %s %s %d ", nick, id, self.x, self.y, self.a, self.text[1], self.text[2], self.curr)
	
	if self.attach then
		str = str .. self.attach
	end
	
	return str
end
