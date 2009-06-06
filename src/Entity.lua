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
local function polygon(p,x,y,r,sx,sy,self)

	local q = {}
	local N = #p/2
	
	local cx = p.cx or 0
	local cy = p.cy or 0
	
	x = x or 0
	y = y or 0
	
	r = r or 0
	r = r/180*math.pi
	
	sx = sx or 1
	sy = sy or sx
	
	for i = 1,N do
		local u = (p[2*i-1] - cx) * sx
		local v = (p[2*i] - cy) * sy
		
		local u2 = u * math.cos(r) - v * math.sin(r) + x
		local v2 = u * math.sin(r) + v * math.cos(r) + y
		
		q[2*i-1] = u2
		q[2*i] = v2
	end
	
	LG.setColor(LG.newColor(100,100,100))
	LG.polygon(love.draw_fill,q)
	
	if self == Table.hot then
		LG.setColor(LG.newColor(255,0,0))
		LG.setLineWidth(4)
	else
		LG.setColor(LG.newColor(0,0,0))
		LG.setLineWidth(1)
	end
	LG.polygon(love.draw_line,q)
	
end


-- The entities on client side are the common ones, with added stuff for drawing, etc.

love.filesystem.require("common/Entity.lua")


-- draws a rectangle of the size of the entity
-- usefull for the generic dummy entity
-- or as a debug draw for others
function Entity:draw()
	
	if not self.visible then return end
	
	LG.setColor(LG.newColor(100,100,100))
	
	local x,y = Table:game2screen(self.x,self.y)
	local s2
	if self.s2 then
		s2 = self.s2 * Table.zoom
	else
		s2 = nil
	end
	
	local w,h = self:getsize()
	w,h = w/2, h/2
	local p = {-w,-h,w,-h,w,h,-w,h}
	polygon(p,x,y,self.a,self.s*Table.zoom,s2,self)
	
	-- draw dragging ghost
	if self.dragged then
		polygon(p,love.mouse.getX()-self.dragx,
			love.mouse.getY()-self.dragy,self.a,self.s*Table.zoom,s2,self)
	end
end

-- on this generic entity, it's dummy
-- will be overloaded by others
function Entity:getsize()
	return 100,100
end

-- tells if the game coordinates x,y are inside the rectangle
function Entity:isinside(x,y)
	local w,h = self:getsize()
	local r = math.rad(-self.a)
	local sx,sy = self.s, self.s2 or self.s
	
	-- put the point in the shape's referential
	local x,y = x - self.x, y - self.y
	
	-- in rotation too
	local x2 = x * math.cos(r) - y * math.sin(r)
	local y2 = x * math.sin(r) + y * math.cos(r)
	
	-- checking insideness of a rectangle is quite easy, now
	return x2 <= w/2*sx and x2 >= -w/2*sx and y2 <= h/2*sy and y2 >= -h/2*sy
end


-- mousepressed/released are called for all entities
-- x,y are in screen space

function Entity:mousepressed(x,y,button)

	-- Left click: start dragging if we're hot
	if button == love.mouse_left and Table.hot == self then
		local cx,cy = Table:game2screen(self.x,self.y)
		self.dragged = true
		self.dragx = x - cx
		self.dragy = y - cy
	end
end

function Entity:mousereleased(x,y,button)

	-- if we were dragging, stop and ask server to move entity
	if button == love.mouse_left and self.dragged then
		self.dragged = false
		
		local x,y = Table:screen2game(x,y)
		TcpClient:send(FMT("MOVE %d %d %d", self.id, x-self.dragx, y-self.dragy))
	end
end

function Entity:update(dt)

	
end

