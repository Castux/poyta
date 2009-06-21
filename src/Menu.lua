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


Menu = class()

-- A contextual menu that objects can fill in with menu items that callback
-- when they are clicked

function Menu:init(x,y)
	
	self.items = {}
	
	-- center coordinates (in screen space, of course)
	self.x = x
	self.y = y
	
	return self
end

function Menu:draw()
	
	for i,v in ipairs(self.items) do
		v:draw()
	end
end

function Menu:isinside(x,y)
	
	for i,v in ipairs(self.items) do
		if v:isinside(x,y) then
			return v
		end
	end
end

function Menu:mousepressed(x,y,button)
	
	local x,y,button = x,y,button
	
	-- don't intercept anything if not active
	if #self.items < 1 then
		return x,y,button
	end
	
	-- else, forward to items
	for i,v in ipairs(self.items) do
		x,y,button = v:mousepressed(x,y,button)
		
		-- allow items to intercept clicks
		if not (x and y and button) then
			return
		end
	end
	
	-- if no one got it, the click was elsewhere, so the menu dies
	-- and we intercept by not returning anything
	self:init()	
end

-- the important thing: adding elements to the menu
-- if callback return true, menu is not initialised after it returns,
-- allowing for chain-menuing

function Menu:add(img, callback)
	
	-- add a new MenuItem to the list
	table.insert(self.items, MenuItem(img, callback))
	
	-- recompute positions
	local size = 0	-- use maximum dimension as a reference
	for i,v in ipairs(self.items) do
		local s = math.max(v:getsize())
		if s > size then
			size = s
		end
	end
	
	local N = #self.items
	
		-- make a circle with perimeter big enough to hold everything
	local rad = size * N * 0.8 / (2 * math.pi)		-- 0.7 is just a margin
	if rad < size then rad = size end
	
		-- place objects along it
	for i,v in ipairs(self.items) do
		local x,y = rad * math.cos(i / N * 2 * math.pi), rad * math.sin(i / N * 2 * math.pi)
		v.x = x + self.x
		v.y = y + self.y
	end
	
end

-----------------------------------------------------------------------
--[[ MenuItem]]--------------------------------------------------------
-----------------------------------------------------------------------

MenuItem = class()

-- elem can be either an image, or a string

function MenuItem:init(elem, callback)
	
	self.elem = elem
	self.callback = callback
	
	self.lineh = 20
	self.font = LG.newFont(love.default_font, self.lineh)
	
	-- center coordinates (in screen space, of course)
	self.x = 0
	self.y = 0
	
	return self
end

function MenuItem:getsize()
	
	if type(self.elem) == "string" then
		return self.font:getWidth(self.elem), self.lineh
	else
		return self.elem:getWidth(), self.elem:getHeight()
	end
end

function MenuItem:draw()
	
	local margin = 2

	-- make a frame	
	if EventHandler.hot == self then
		LG.setColor(LG.newColor(0,0,0,100))
	else
		LG.setColor(LG.newColor(255,255,255,100))
	end
	
	local w,h = self:getsize()
	LG.rectangle(love.draw_fill, self.x - w/2 - margin, self.y - h/2 - margin, w + 2*margin, h  + 2*margin)
	
	-- then the element
	local x,y
	if type(self.elem) == "string" then
		x = self.x - self:getsize()/2
		y = self.y + self.lineh/2
		LG.setColor(LG.newColor(0,0,0))
		LG.setFont(self.font)
	else
		x,y = self.x, self.y
	end
	
	LG.draw(self.elem, x, y)
end

function MenuItem:isinside(x,y)
	
	local w,h = self:getsize()
	
	if math.abs(x - self.x) < w/2 and math.abs(y - self.y) < h/2 then
		return self
	end
end

function MenuItem:mousepressed(x,y,button)
	
	-- if left click on us
	if EventHandler.hot == self and button == love.mouse_left then
		
		-- call callback
		if not self.callback() then
			-- kill menu if callback didn't ask to keep it up by returning true
			Menu:init()
		end
		
	-- forward otherwise	
	else
		return x,y,button
	end
end
