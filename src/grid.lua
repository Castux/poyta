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

Grid = class()

local function inRange(x,a,b)
	return x >= a and x <= b
end

function Grid:init(w,h)
	self.w = w
	self.h = h
	
	self.grid = {}
	
	return self
end

function Grid:inrange(x,y)
	return inRange(x,1,self.w) and inRange(y,1,self.h)
end

function Grid:index(x,y)
	return (y-1)*self.w + x
end

function Grid:get(x,y)

	assert(self:inrange(x,y), "Index "..x..","..y.." not in grid range.")
	
	return self.grid[self:index(x,y)]
end

function Grid:set(x,y,elem)

	assert(self:inrange(x,y), "Index "..x..","..y.." not in grid range.")
	
	self.grid[self:index(x,y)] = elem
	
	return self
end

function Grid:foreach(func)
	for i = 1,self.w * self.h do
		self.grid[i] = func(self.grid[i])
	end
	
	return self
end

function Grid:setall(elem)
	for i = 1,self.w * self.h do
		self.grid[i] = elem
	end
	
	return self
end

function Grid:resize(w,h)
	local tmp = Grid(w,h)
	
	u = math.min(w,self.w)
	v = math.min(h,self.h)
	
	for i = 1,u do
		for j = 1,v do
			tmp:set(i,j, self:get(i,j) ) 
		end
	end
	
	self.w = w
	self.h = h
	self.grid = tmp.grid
	
	return self
end
