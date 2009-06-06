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


Console = class()

function Console:init(w,h,font,size,callback)
	
	self.w = w or 80
	self.h = h or 24
	self.size = size or 12
		
	self.font = LG.newFont(font or love.default_font, self.size)
	
	-- display
	self.lines = {}
	self.current = 1
	
	-- command line
	self.cursor = 1
	self.command = ""
	
	-- history
	self.history = {}
	self.histind = 1
	self.histtmp = ""	--holds the current command when checking history
	
	-- exec callback
	self.callback = callback or function(self,line) end
	
	return self
end

function Console:draw(x,y)
	local x,y = x or 1, y or 1
	
	LG.setColor(LG.newColor(0,0,150))
	LG.setLineWidth(1)
	-- frame
	
	LG.rectangle(love.draw_line, x, y, self.w*self.size*0.6 + 4 , self.h*self.size + 4)
	
	LG.setFont(self.font)
	
	-- history lines
	
	for i = self.current, self.current + self.h - 1 do
		LG.draw(self.lines[i] or "", x + 2, y + (i-self.current+1)*self.size + 2)
	end
	
	-- cursor
	local curs = "  " .. string.rep(" ", self.cursor-1) .. string.char(127)
	LG.draw(curs, x + 2, y + self.h*self.size + 2)
	
	-- then the command line
	LG.draw("> " .. self.command, x + 2, y + self.h*self.size + 2)
end

function Console:input(key)
	local key = key
	
	-- ascii character
	if key <= 126 and key >= 32 then
		local shift = love.keyboard.isDown(love.key_lshift) or love.keyboard.isDown(love.key_rshift)

		if key <= 122 and key >= 97 and shift then
			-- caps
			key = key - (97-65)
		end
		
		if #self.command < self.w then
			self:insert(string.char(key))
		end
	
	-- special commands
	elseif key == love.key_backspace then	-- remove last
		self:insert()
		
	elseif key == love.key_return then	-- exec baby!
		self:execute()

	-- cursor movement
	elseif key == love.key_left and self.cursor > 1 then
		self.cursor = self.cursor - 1
	elseif key == love.key_right and self.cursor <= #self.command then
		self.cursor = self.cursor + 1

	-- history functions
	elseif key == love.key_up and self.histind > 1 then
		self.histind = self.histind - 1
		
		if self.histind == #self.history then	-- remember command if this is the first history query
			self.histtmp = self.command
		end
		
		self.command = self.history[self.histind]
		self.cursor = #self.command + 1
		
	elseif key == love.key_down and self.histind <= #self.history then
		if self.histind < #self.history then
			self.histind = self.histind + 1
			self.command = self.history[self.histind]
			
		elseif self.histind == #self.history then	--if back to original command
			self.histind = self.histind + 1
			self.command = self.histtmp
		end
		self.cursor = #self.command + 1
	end
end

function Console:execute()
	
	if self.command == "" then return end
	
	-- will do something else here... like call a callback
	self:callback(self.command)
	--
	
	table.insert(self.history,self.command)
	self.histind = #self.history + 1
	
	self.command = ""
	self.cursor = 1
end

function Console:print(line)

	self.lines[self.current + self.h - 1] = line
	self.current = self.current + 1
end

-- insert a character at cursor, or backspace is char is nil
function Console:insert(char)
	
	if char then
		self.command = string.sub(self.command,1,self.cursor-1) .. char .. string.sub(self.command,self.cursor)
		self.cursor = self.cursor + 1
	elseif self.cursor > 1 then	-- can't backspace if at beginning
		self.command = string.sub(self.command,1,self.cursor-2) .. string.sub(self.command,self.cursor)
		self.cursor = self.cursor - 1
	end
end
