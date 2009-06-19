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
				self:flip()
			end)
			Menu:add("Flip randomly", function()
				self:flip(true)
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
	
	-- the font
	self.lineh = 20
	self.font = LG.newFont(love.default_font, self.lineh)
	
end

function Label:getsize()
	return self.font:getWidth(self.text[self.curr]), self.lineh
end

function Label:draw()

	if not self.visible then return end

	local w,h = self:getsize()
	local x,y = self.currx - w/2, self.curry + h/2
	
	if self.attach then
		x = x + Table.ids[id].x
		y = y + Table.ids[id].y
	end
	
	x,y = Table:game2screen(x,y)
	
	local q = {}			-- screen space
		
	for i = 1,4 do
		q[2*i-1],q[2*i] = Table:game2screen(self.poly[2*i-1], self.poly[2*i])
	end
	
	if EventHandler.hot == self then
		
		
		LG.setColor(LG.newColor(0,0,0,100))
		LG.polygon(love.draw_fill, q)
	end
	
	LG.setFont(self.font)
	LG.setColor(LG.newColor(0,0,0))
	LG.draw(self.text[self.curr], q[7], q[8], self.curra, Table.zoom)

end
