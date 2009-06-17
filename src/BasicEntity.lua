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

function NImage:draw()

	if not self.visible then return end
	
	-- basic drawing
	local x,y = Table:game2screen(self.currx, self.curry)
	local s2 = self.s2 or self.s
	
	if EventHandler.hot == self then
		-- draw thin frame
		local q = {}			-- screen space

		for i = 1,4 do
			q[2*i-1],q[2*i] = Table:game2screen(self.poly[2*i-1], self.poly[2*i])
		end
		
		LG.setColor(LG.newColor(100,100,100))
		LG.setLineWidth(1)
		LG.polygon(love.draw_line,q)
	end
	
	LG.draw(self.images[self.curr], x, y, self.curra, self.s*Table.zoom, s2*Table.zoom)
	
	-- corner proximity
	if not (self.dragged or self.rotated) and EventHandler.hot == self then
		local x,y = Table:screen2game(love.mouse.getX(),love.mouse.getY())
		x,y = self:isnearcorner(x,y,self:getcornerradius())
		if x and y then
			LG.circle(love.draw_fill, love.mouse.getX(), love.mouse.getY(), 5) 
		end
	end
	
	-- dragging ghost
	if self.dragged then
		x = love.mouse.getX() - self.dragx
		y = love.mouse.getY() - self.dragy
		
		LG.setColor(LG.newColor(255,255,255,100))
		LG.setColorMode(love.color_modulate)
		LG.draw(self.images[self.curr], x, y, self.curra, self.s*Table.zoom, s2*Table.zoom)
		LG.setColorMode(love.color_normal)
	end
	
	-- rotating ghost
	if self.rotated then
		local x,y = Table:screen2game(love.mouse.getX(),love.mouse.getY())
		local ang = math.deg(math.atan2(y-self.y,x-self.x)) - self.rotang
		
		x,y = Table:game2screen(self.currx, self.curry)
		
		LG.setColor(LG.newColor(255,255,255,100))
		LG.setColorMode(love.color_modulate)
		LG.draw(self.images[self.curr], x, y, self.curra + ang, self.s*Table.zoom, s2*Table.zoom)
		LG.setColorMode(love.color_normal)
	end	
end
