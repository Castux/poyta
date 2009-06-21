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

TextInput = class()

function TextInput:init(x,y,callback,lineh)
	
	self.x = x or 0
	self.y = y or 0
	self.lineh = lineh or 20
		
	self.font = LG.newFont("VeraMono.ttf", self.lineh)

	-- text
	self.cursor = 1
	self.text = ""
	
	-- active or not
	if x and y and callback then
		self.active = true
	else
		self.active = false
	end
	
	-- "enter" callback
	self.callback = callback or function(line) end
	
	return self
end

function TextInput:getsize()

		return self.font:getWidth(self.text), self.lineh
end

function TextInput:draw()
	
	if not self.active then
		return
	end
	
	local margin = 2

	-- make a frame	
	if EventHandler.hot == self then
		LG.setColor(LG.newColor(0,0,0,100))
	else
		LG.setColor(LG.newColor(255,255,255,100))
	end
	
	local w,h = self:getsize()
	LG.rectangle(love.draw_fill, self.x - w/2 - margin, self.y - h/2 - margin, w + 2*margin, h  + 2*margin)
	
	-- then the text
	LG.setFont(self.font)
	
	local x,y
	x = self.x - self:getsize()/2
	y = self.y + self.lineh/2
	LG.setColor(LG.newColor(0,0,0))
	LG.draw(self.text,x,y)
	
	-- cursor
	local curs = string.rep(" ", self.cursor-1) .. string.char(127)
	LG.draw(curs, x, y)
end

function TextInput:isinside(x,y)
	
	if not self.active then
		return
	end
	
	local w,h = self:getsize()
	
	if math.abs(x - self.x) < w/2 and math.abs(y - self.y) < h/2 then
		return self
	end
end

function TextInput:mousepressed(x,y,button)
	
	if not self.active then
		return x,y,button
	end
	
	-- if click outside of us, disapear
	if EventHandler.hot ~= self then
		self:init()
	end
end


function TextInput:input(key)
	local key = key
	
	-- ascii character 
	-- WAITING FOR LÖVE 0.6 AND A PROPER TEXT INPUT
	if key <= 126 and key >= 32 then
		local shift = love.keyboard.isDown(love.key_lshift) or love.keyboard.isDown(love.key_rshift)

		if key <= 122 and key >= 97 and shift then
			-- caps
			key = key - (97-65)
		end
		
		self:insert(string.char(key))
	
	elseif key >= love.key_kp0 and key <= love.key_kp9 then
		self:insert(string.char(key - love.key_kp0 + love.key_0))
	
	-- special commands
	elseif key == love.key_backspace then	-- remove last
		self:insert()
		
	elseif key == love.key_return then	-- exec baby!
		self:execute()

	-- cursor movement
	elseif key == love.key_left and self.cursor > 1 then
		self.cursor = self.cursor - 1
	elseif key == love.key_right and self.cursor <= #self.text then
		self.cursor = self.cursor + 1
	end
end

function TextInput:keypressed(key)
	
	if not self.active then
		return key
	end
	
	-- intercept all key events
	self:input(key)	
end

function TextInput:execute()
	
	-- call the callback
	self.callback(self.text)
	
	-- and reset
	self:init()
end

-- insert a character at cursor, or backspace is char is nil
function TextInput:insert(char)
	
	if char then
		self.text = string.sub(self.text,1,self.cursor-1) .. char .. string.sub(self.text,self.cursor)
		self.cursor = self.cursor + 1
	elseif self.cursor > 1 then	-- can't backspace if at beginning
		self.text = string.sub(self.text,1,self.cursor-2) .. string.sub(self.text,self.cursor)
		self.cursor = self.cursor - 1
	end
end
