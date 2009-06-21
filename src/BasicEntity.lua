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

love.filesystem.require("common/BasicEntity.lua")

-- We add to the common BasicEntities all the graphical related functions


-------------------------------------------------------------
--[[ N-Image ]]----------------------------------------------
-------------------------------------------------------------

function NImage:initview()
	
	-- init as a regular entity
	NImage.super.initview(self)
	
	-- link to the actual sprites
	self.images = {}	
	for i,v in ipairs(self.sprites) do
		self.images[i] = Drawer:resolvename(v)
	end
	
	return self
end

function NImage:getsize()
	return self.images[self.curr]:getWidth(), self.images[self.curr]:getHeight()
end

-- overload the partial drawing method only, to inherit the computations done at Entity level
function NImage:drawentity(alpha,dx,dy,da)
	
	local alpha = alpha or 255
	local dx,dy,da = dx or 0, dy or 0, da or 0
	
	local x,y = Table:game2screen(self.currx, self.curry)
	
	local s2 = self.s2 or self.s
	
	LG.setColor(LG.newColor(self.r,self.g,self.b,alpha))
	LG.setColorMode(love.color_modulate)
	LG.draw(self.images[self.curr], x + dx, y + dy, self.curra + da, self.s*Table.zoom, s2*Table.zoom)
	LG.setColorMode(love.color_normal)
end

function NImage:mousepressed(x,y,button)
	
	-- inherit all the fancy stuff from parent class
	NImage.super.mousepressed(self,x,y,button)
	
	-- add others specific to NImage
	
	-- right click: add stuff to contextual menu
	if button == love.mouse_right and EventHandler.hot == self then
		
		-- flipping the NImage
		if #self.sprites > 1 then
			Menu:add("Flip", function()
				TcpClient:send("FLIP " .. self.id)
			end)
			Menu:add("Flip randomly", function()
				TcpClient:send("FLIP " .. self.id .. " random")
			end)
		end
		
		-- pick color
		Menu:add("Change color", function()
			colorpicker(function(r,g,b)
				TcpClient:send(FMT("SETCOLOR %d %d %d %d", self.id, r, g, b))
			end)
			
			return true	-- tell menu we don't want it to be erased, since colopicker sets it up again
		end)
	end
end


-------------------------------------------------------------
--[[ Label ]]------------------------------------------------
-------------------------------------------------------------

function Label:initview()
	
	-- init as a regular entity
	Label.super.initview(self)
	
	-- check we know of the entity before accessing its fields all the time
	if self.attach and not Table.ids[self.attach] then
		self.attach = nil
	end
	
	if self.attach then
		-- remember the initial difference with attach
		self.dx = self.x
		self.dy = self.y
		
		-- attach yourself
		self.x = self.dx + Table.ids[self.attach].x
		self.y = self.dy + Table.ids[self.attach].y
		
		-- avoid movement when loading
		self.currx = self.dx + Table.ids[self.attach].x
		self.curry = self.dy + Table.ids[self.attach].y
	end
		
	-- the font
	self.lineh = 20
	self.font = LG.newFont(love.default_font, self.lineh)
	
end

function Label:attachto(target)
	
	-- reproduce normal label code
	
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
	
	-- and then update view related variables
	if self.attach then
		-- remember the initial difference with attach
		self.dx = self.x
		self.dy = self.y
		
		-- avoid movement
		self.currx = self.dx + Table.ids[self.attach].x
		self.curry = self.dy + Table.ids[self.attach].y
	end
end

-- when we receive a move command, we have to make it relative, if we're attached
function Label:set(x,y,a)
	
	self.a = a or self.a
	
	if self.attach then
		self.dx = x or self.dx
		self.dy = y or self.dy
	else
		self.x = x or self.x
		self.y = y or self.y
	end
	
	return self
end

function Label:getstring()
	local s = self.text[self.curr]
	if s == "" then s = "<***>" end
	
	return s
end

function Label:getsize()
	return self.font:getWidth(self:getstring()), self.lineh
end

function Label:update(dt)

	Label.super.update(self,dt)
	
	-- if our attach died, become independent
	if not Table.ids[self.attach] then
		self.attach = nil
	end
	
	-- if we're attached, update our coords
	if self.attach then
		self.x = self.dx + Table.ids[self.attach].x
		self.y = self.dy + Table.ids[self.attach].y
	end
end

function Label:drawentity(alpha,dx,dy,da)
	
	local alpha = alpha or 255
	local dx,dy,da = dx or 0, dy or 0, da or 0
	
	local w,h = self:getsize()
	local x,y = self.currx - w/2, self.curry + h/2
	
	x,y = Table:game2screen(x,y)
	
	-- the annoying part where we have to compute the position of the corner
	if self.curra + da ~= 0 then
		local poly = self:corners(da)
		x,y = Table:game2screen(poly[7], poly[8])
	end
	
	LG.setFont(self.font)
	LG.setColor(LG.newColor(0,0,0,alpha))
	LG.draw(self:getstring(), x + dx, y + dy, self.curra + da, Table.zoom)
end

-- in case of attachment, the order to send when dropping is different (relative)
-- and when dropping on something else, propose attaching

function Label:mousereleased(x,y,button)

	-- if we were dragging, and dropped on something, attach
	if button == love.mouse_left and self.dragged and EventHandler.hot and EventHandler.hot ~= self then
		self.dragged = false
		
		local target = EventHandler.hot
		if not target:isa(Entity) then
			return
		end
		
		Menu:init(x,y)
		Menu:add("Attach label",function()
			TcpClient:send(FMT("ATTACH %d %d", self.id, target.id))
		end)
	
	-- if we were dragging, stop and ask server to move entity
	elseif button == love.mouse_left and self.dragged then
		self.dragged = false
		
		local x,y = Table:screen2game(x-self.dragx,y-self.dragy)
		if self.attach then
			x = x - Table.ids[self.attach].x
			y = y - Table.ids[self.attach].y
		end
		
		TcpClient:send(FMT("MOVE %d %d %d", self.id, x, y))
	
	-- same for rotation
	elseif button == love.mouse_left and self.rotated then
		self.rotated = false
		
		local x,y = Table:screen2game(love.mouse.getX(),love.mouse.getY())
		local ang = math.deg(math.atan2(y-self.y,x-self.x)) - self.rotang + self.a
		
		TcpClient:send(FMT("ROTATE %d %f", self.id, ang % 360))
	end
end

function Label:mousepressed(x,y,button)
	
	-- inherit all the fancy stuff from parent class
	NImage.super.mousepressed(self,x,y,button)
	
	-- add others specific to label
	
	-- right click: add stuff to contextual menu
	if button == love.mouse_right and EventHandler.hot == self then
		
		-- flipping		
		Menu:add("Flip", function()
			TcpClient:send("FLIP " .. self.id)
		end)
		Menu:add("Flip randomly", function()
			TcpClient:send("FLIP " .. self.id .. " random")
		end)
		
		-- text changing
		Menu:add("Change text", function()
			TextInput:init(x,y + 1.5*self.lineh,function(line)
				TcpClient:send("SETLABEL " .. self.id .. " " .. TcpClient:escapestring(line))
			end)
		end)
		
		-- detaching
		if self.attach then
			Menu:add("Detach label", function()
				TcpClient:send("ATTACH " .. self.id)
			end)
		end
	end
end
