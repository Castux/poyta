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
local LG = love.graphics
local function polygon(p,x,y,r,sx,sy)

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
	
	LG.polygon(love.draw_fill,q)
end


-- The entities on client side are the common ones, with added stuff for drawing, etc.

love.filesystem.require("common/Entity.lua")

function Entity:draw()
	
	LG.setColor(LG.newColor(100,100,100))
	
	local p = {-50,-50,50,-50,50,50,-50,50}
	polygon(p,self.x,self.y,self.a,self.s,self.s2)
	
	
end



