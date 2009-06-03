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

-- make handy shortcut
local LG = love.graphics

-- make the console a subclass of Grid
love.filesystem.require("grid.lua")
Console = class(Grid)

function Console:init(w,h,font,size)
	
	self.super:init(w,h)	-- init the Grid
	self.size = size or 12
	
	self:foreach(function()
		return string.char(math.random(32,126))
	end)
	
	self.font = love.graphics.newFont(font or love.default_font, self.size)
	
	return self
end

function Console:draw(x,y)
	local x,y = x or 1, y or 1
	local line
	
	LG.setFont(self.font)
		
	for l = 1,self.h do
		line = ""
		for c = 1,self.w do
			line = line .. (self:get(c,l) or " ")
		end
		LG.draw(line, x, y + l*self.size)
	end
end
