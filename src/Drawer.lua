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


Drawer = class()

-- At initialisation, the drawer takes care of loading all the packs.
-- packs is a table of values, which are false if the pack is not loaded yet, and
-- a table of Images if they are.
-- (for now we load everything, we'll care about memory later)

function Drawer:init(w)
	
	self.packs = {}
	self.pdir = "packs"
	self.w = w or 100
	self.lineh = 20		-- height of the lines in packs list view
	self.imgh = 100		-- size of the squares in pack view
	
	self.view = nil		-- nil when seeing the list of packs, a pack when seeing this pack
	
	self.font = LG.newFont(love.default_font, self.lineh)
	
	-- scanning the packs folder (expected to be in the "save directory")
	local ls = LF.enumerate(self.pdir)
	for i,v in ipairs(ls) do
		if LF.isDirectory(self.pdir .. "/" .. v) then
			self:loadpack(v)
		end
	end
	
	return self
end

function Drawer:loadpack(str)
	local path = self.pdir .. "/" .. str
	
	-- is string valid?
	if str == "" or not str then return end
	
	-- do we already have such a pack?
	if self.packs[str] then 
		Console:print("[Warning] Trying to add pack " .. str .. " which already exists.")
		return
	end
	
	-- make the pack
	self.packs[str] = {}
	local p = self.packs[str]
	
	-- get all the files
	local ls = LF.enumerate(path)
	for i,v in ipairs(ls) do
		local f = path .. "/" .. v
		if LF.isFile(f) then
			p[v] = LG.newImage(f)
		end
	end
	
	Console:print("Loaded pack " .. str)
	
	return p
end


function Drawer:draw()
	
	local x = LG.getWidth() - self.w
	local hot
	
	if EventHandler.hot == self then
		LG.setColor(LG.newColor(255,255,255,200))
		hot = math.floor(love.mouse.getY()/self.lineh) + 1
	else
		LG.setColor(LG.newColor(255,255,255,100))
	end
	
	LG.rectangle(love.draw_fill,x,0,self.w,LG.getHeight())
	
	LG.setFont(self.font)

	self.view = "basic"
	if not self.view then
		local i = 1
		for k,v in pairs(self.packs) do
			if hot == i then
				LG.setColor(LG.newColor(200,0,0))
			else
				LG.setColor(LG.newColor(0,0,0))
			end
			
			LG.draw(k,x + 10,i*self.lineh)
			i = i + 1
		end
	else
		local i = 0
		for k,v in pairs(self.packs[self.view]) do
			local max = math.max(v:getHeight(), v:getWidth())
			local zoom = 1
			if max > self.imgh then
				zoom = self.imgh/max
			end
			LG.draw(v,x + self.w/2, i*self.imgh + self.imgh/2,zoom)
			i = i + 1
		end
	
	
	
	end
end

function Drawer:isinside(x,y)
	
	if x >= LG.getWidth() - self.w then
		return self
	end
end
