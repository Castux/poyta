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

require "common/class"


Console = class()

function Console:init(x,y,w,h,font,size,callback)
	
	self.x = x or 0
	self.y = y or 0
	self.w = w or 80
	self.h = h or 24
	self.size = size or 12
		
	self.font = LG.newFont(font or love.default_font, self.size)
	
	self.charwidth = self.font:getWidth(" ")
	

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

function Console:draw()
	local x,y = self.x, self.y
	
	-- frame
	LG.setColor(LG.newColor(0,0,150))
	if EventHandler.hot == self then
		LG.setLineWidth(3)
	else
		LG.setLineWidth(2)
	end
	
	LG.rectangle(love.draw_line, x, y, self.w*self.charwidth + 4 , self.h*self.size + 4)
	
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
	-- WAITING FOR LÖVE 0.6 AND A PROPER TEXT INPUT
	local char = text_input(key)
	if char then
		self:insert(char)
		
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
	
	if char and #self.command < self.w then
		self.command = string.sub(self.command,1,self.cursor-1) .. char .. string.sub(self.command,self.cursor)
		self.cursor = self.cursor + 1
	elseif self.cursor > 1 then	-- can't backspace if at beginning
		self.command = string.sub(self.command,1,self.cursor-2) .. string.sub(self.command,self.cursor)
		self.cursor = self.cursor - 1
	end
end

-- answer to EventHandler by returning self if x,y is in the console

function Console:isinside(x,y)
	
	if x >= self.x and x <= self.x + self.w*self.charwidth + 4 and
		y >= self.y and y <= self.y + self.h*self.size + 4
	then
		return self
	else
		return nil
	end
end

-- Event management methods

function Console:keypressed(key)
	
	-- intercept all key events
	self:input(key)	
end
