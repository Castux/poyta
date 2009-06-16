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

DrawerItem = class()

function DrawerItem:init(x,y,name,sprite)
	self.x = x
	self.y = y
	self.name = name
	self.sprite = sprite
	
	return self
end

function DrawerItem:draw()
	local max = math.max(self.sprite:getHeight(), self.sprite:getWidth())
	local zoom = 1
	if max > Drawer.imgh then
		zoom = Drawer.imgh/max
	end
	
	if EventHandler.hot == self then
		LG.setColorMode(love.color_modulate)
		LG.setColor(LG.newColor(0,0,255,100))
	end
	
	LG.draw(self.sprite, self.x, self.y, 0, zoom)
	LG.setColorMode(love.color_normal)	
end


function DrawerItem:isinside(x,y)
	if math.abs(self.x - x) <= Drawer.imgh/2 and math.abs(self.y - y) <= Drawer.imgh/2 then
		return self
	end
end
