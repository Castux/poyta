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

local function dist2(x,y,u,v)
	return (x-u)^2 + (y-v)^2
end


-- The entities on client side are the common ones, with added stuff for drawing, etc.

love.filesystem.require("common/Entity.lua")

function Entity:initview()
	
	-- smooth movement
	self.currx = self.x
	self.curry = self.y
	
	-- smooth rotation
	self.curra = self.a 
	
	-- geometry information
	self.poly = {}
	
	-- GUI stuff
	self.dragged = false
	self.dragx = 0		-- relative position of the mouse wrt entity center at click time
	self.dragy = 0
		
	self.rotated = false
	self.rotang = 0 	-- angle of the click point around the entity center at click time
	
	self.locked = false	-- trying to drag a locked entity drags the table instead
	
	return self
end

-- compute position of corners in gamespace, return them as a list of 8 elements
-- {x1,y1,x2,y2,...}
-- takes optional argument a, which is added to the angle during computation

function Entity:corners(a)
	
	local w,h = self:getsize()
	w,h = w/2, h/2
	local p = {-w,-h,w,-h,w,h,-w,h}
	
	local q = {}
	local N = #p/2
	
	local cx = self.currx
	local cy = self.curry
	
	local r = math.rad(self.curra + (a or 0))
	
	local sx = self.s
	local sy = self.s2 or sx
	
	for i = 1,N do
		local u = p[2*i-1] * sx
		local v = p[2*i] * sy
		
		local u2 = u * math.cos(r) - v * math.sin(r)
		local v2 = u * math.sin(r) + v * math.cos(r)
		
		q[2*i-1] = u2 + cx
		q[2*i] = v2 + cy
	end
	
	return q
end

-- draws a rectangle of the size of the entity
-- usefull for the generic dummy entity
-- or as a debug draw for others
function Entity:draw()
	
	if not self.visible then return end

	local q = {}			-- screen space
	
	for i = 1,4 do
		q[2*i-1],q[2*i] = Table:game2screen(self.poly[2*i-1], self.poly[2*i])
	end
	
	LG.setColor(LG.newColor(100,100,100))
	LG.polygon(love.draw_fill,q)
	
	if self == EventHandler.hot then
		LG.setColor(LG.newColor(255,0,0))
		LG.setLineWidth(4)
	else
		LG.setColor(LG.newColor(0,0,0))
		LG.setLineWidth(1)
	end
	LG.polygon(love.draw_line,q)
	
	-- corner proximity
	if not (self.dragged or self.rotated) and EventHandler.hot == self then
		local x,y = Table:screen2game(love.mouse.getX(),love.mouse.getY())
		x,y = self:isnearcorner(x,y,self:getcornerradius())
		if x and y then
			x,y = Table:game2screen(x,y)
			
			LG.setColor(LG.newColor(255,0,0,100))
			LG.circle(love.draw_fill,x,y,self:getcornerradius()*Table.zoom, 50)
		end
	end
	
	-- draw dragging ghost
	if self.dragged then
		local x,y = Table:game2screen(self.x,self.y)
		for i = 1,4 do
			q[2*i-1] = q[2*i-1] + love.mouse.getX() - x - self.dragx 
			q[2*i] = q[2*i] + love.mouse.getY() - y - self.dragy
		end
		
		LG.setColor(LG.newColor(100,100,100,100))
		LG.polygon(love.draw_fill,q)
	end
	
	-- or rotating ghost
	if self.rotated then
		local x,y = Table:screen2game(love.mouse.getX(),love.mouse.getY())
		local ang = math.deg(math.atan2(y-self.y,x-self.x)) - self.rotang
		
		local p = self:corners(ang)	-- get the corners, with added angle equal to what we dragged
		
		for i = 1,4 do
			p[2*i-1],p[2*i] = Table:game2screen(p[2*i-1], p[2*i])
		end
		
		LG.setColor(LG.newColor(100,255,100,100))
		LG.polygon(love.draw_fill,p)
		
		
	end	
end

-- on this generic entity, it's fixed
-- will be overloaded by others
function Entity:getsize()
	return 100,100
end

function Entity:getcornerradius()
	local w,h = self:getsize()
	return math.min(w,h) / 4
end


-- tells if the game coordinates x,y are inside the rectangle
function Entity:isinside(x,y)
	local w,h = self:getsize()
	local r = math.rad(-self.curra)
	local sx,sy = self.s, self.s2 or self.s
	
	-- put the point in the shape's referential
	local x,y = x - self.currx, y - self.curry
	
	-- in rotation too
	local x2 = x * math.cos(r) - y * math.sin(r)
	local y2 = x * math.sin(r) + y * math.cos(r)
	
	-- checking insideness of a rectangle is quite easy, now
	return x2 <= w/2*sx and x2 >= -w/2*sx and y2 <= h/2*sy and y2 >= -h/2*sy
end

-- tell if given coords are at less than rad of a corner of the entity,
-- and returns the coordinates in gamespace and the number (1 is top left, then clockwise)
-- returns nil if no corner is nearby

function Entity:isnearcorner(x,y,rad)
	
	for i = 1,4 do
		if dist2(x,y,self.poly[2*i-1],self.poly[2*i]) < rad^2 then
			return self.poly[2*i-1],self.poly[2*i],i
		end
	end

	-- if none, return nil
	return nil
end

-- mousepressed/released are called for all entities
-- x,y are in screen space

function Entity:mousepressed(x,y,button)
	
	
	-- Left click: start dragging if we're hot, or rotating if near corner
	if button == love.mouse_left and EventHandler.hot == self and not self.locked then
		local gx,gy = Table:screen2game(x,y)
		local cox,coy = self:isnearcorner(gx,gy,self:getcornerradius())
		
		if cox and coy then	-- rotate
			self.rotated = true
			self.rotang = math.deg(math.atan2(gy - self.y, gx - self.x))
			
		else			-- drag
			local cx,cy = Table:game2screen(self.x,self.y)
			self.dragged = true
			self.dragx = x - cx
			self.dragy = y - cy
		end
		
	end
	
	-- right click: start contextual menu
	if button == love.mouse_right and EventHandler.hot == self then
		Menu:init(x,y)
		
		-- delete
		Menu:add("Delete", function()
			TcpClient:send("DELETE " .. self.id)
		end)
		
		-- switch lock
		local str
		if self.locked then
			str = "Unlock"	
		else
			str = "Lock"
		end
		Menu:add(str, function()
			self.locked = not self.locked
		end)
		
		-- change altitude
		Menu:add("Altitude" , function()
			Menu:init(x,y)
			Menu:add("Move to back", function()
				TcpClient:send("MOVEZ " .. self.id .. " 1")
			end)
			
			Menu:add("Move to front", function()
				TcpClient:send("MOVEZ " .. self.id .. " " .. (Table.last + 1))
			end)
			
			Menu:add("Move up", function()
				TcpClient:send("MOVEZ " .. self.id .. " " .. (Table:next(self.id) + 1))
			end)
			
			Menu:add("Move down", function()
				TcpClient:send("MOVEZ " .. self.id .. " " .. (Table:next(self.id,-1)))
			end)
			
			return true	-- prevent re-initing the menu
		end)
	end
end

function Entity:mousereleased(x,y,button)

	-- if we were dragging, stop and ask server to move entity
	if button == love.mouse_left and self.dragged then
		self.dragged = false
		
		local x,y = Table:screen2game(x-self.dragx,y-self.dragy)
		TcpClient:send(FMT("MOVE %d %d %d", self.id, x, y))
	
	elseif button == love.mouse_left and self.rotated then
		self.rotated = false
		
		local x,y = Table:screen2game(love.mouse.getX(),love.mouse.getY())
		local ang = math.deg(math.atan2(y-self.y,x-self.x)) - self.rotang + self.a
		
		TcpClient:send(FMT("ROTATE %d %f", self.id, ang % 360))
	end
end

function Entity:update(dt)

	-- the smooth movement thing
	local speed = 10
	
		-- make self.curr* closer to self.*
	local diffx = self.x - self.currx
	local dx = diffx * speed * dt
	if math.abs(dx) > math.abs(diffx) then
		dx = diffx	-- avoid passing over the target and jumping around it
	end
	self.currx = self.currx + dx
	
	local diffy = self.y - self.curry
	local dy = diffy * speed * dt
	if math.abs(dy) > math.abs(diffy) then
		dy = diffy	-- avoid passing over the target and jumping around it
	end
	self.curry = self.curry + dy
	
	-- smooth rotation
	local speed = 6
	
		-- take shortest path
	local diffa = (self.a - self.curra)%360
	if diffa > 180 then
		diffa = diffa - 360
	end
	
	local da = diffa * speed * dt
	if math.abs(da) > math.abs(diffa) then
		da = diffa	-- avoid passing over the target and jumping around it
	end
	self.curra = self.curra + da
	
	-- update the corners data
	self.poly = self:corners()
	
end

