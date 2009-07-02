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
function NImage:dumpcreate(nick, id)
	
	local str = FMT("IMAGE %s %d %d ", nick, id, #self.sprites)
	
	for i,v in ipairs(self.sprites) do
		str = str .. v .. " "
	end
	
	str = str .. "\n"
	
	if self.curr ~= 1 then
		str = str .. FMT("FLIP %s %d %d\n", nick, id, self.curr)
	end
	
	if self.r ~= 255 or self.g ~= 255 or self.b ~= 255 then
		str = str .. FMT("SETCOLOR %s %d %d %d %d\n", nick, id, self.r, self.g, self.b)
	end
	
	return str .. self:dumpstatus(nick,id)
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
		text or "",
		text2 or "",
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
function Label:dumpcreate(nick, id)
	
	local text = self.text[1] or "%s"
	local text2 = self.text[2] or "%s"
	
	local str = FMT("LABEL %s %d %s %s\n", nick, id, text, text2)
	
	if self.attach then
		str = str .. FMT("ATTACH %s %d %d\n", nick, id, self.attach)
	end
	
	if self.curr ~= 1 then
		str = str .. FMT("FLIP %s %d %d\n", nick, id, self.curr)
	end
	
	return str .. self:dumpstatus(nick,id)
end

-- attach and updates coordinates so we don't move in the process
function Label:attachto(target)
	
	-- the detach case
	if not target and self.attach then
		self.x = self.x + Table.ids[self.attach].x
		self.y = self.y + Table.ids[self.attach].y
		
		self.attach = nil
	
	-- the attach case
	else
		self.attach = target
		if Table.ids[self.attach] then
			self.x = self.x - Table.ids[self.attach].x
			self.y = self.y - Table.ids[self.attach].y
		end
	end
end
