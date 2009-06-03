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

love.filesystem.require("common/class.lua")


Console = class()

function Console:init(w,h,font,size)
	
	self.w = w or 80
	self.h = h or 24
	self.size = size or 12
		
	self.font = love.graphics.newFont(font or love.default_font, self.size)
	
	self.lines = {}
	self.current = 1
	
	self.command = ""
	
	return self
end

function Console:draw(x,y)
	local x,y = x or 1, y or 1
	
	LG.setFont(self.font)
	
	-- history lines
	
	for i = self.current, self.current + self.h - 1 do
		LG.draw(self.lines[i] or "", x, y + (i-self.current+1)*self.size)
	end
	
	-- then the command line
	LG.draw("> " .. self.command, x, y + self.h*self.size)
end

function Console:input(key)
	
	if key <= 126 and key >= 32 then	-- map to ascii
		if #self.command < self.w then
			self.command = self.command .. string.char(key)
		end
		
	elseif key == love.key_backspace then	-- remove last
		self.command = string.sub(self.command,1,-2)

	elseif key == love.key_return then	-- exec baby!
		self:execute()
	end
end

function Console:execute()
	
	if self.command == "" then return end
	
	self:print(self.command)
	self.command = ""
end

function Console:print(line)

	self.lines[self.current + self.h - 1] = self.command
	self.current = self.current + 1
end
