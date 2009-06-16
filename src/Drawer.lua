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
love.filesystem.require("DrawerItem.lua")

Drawer = class()

-- At initialisation, the drawer takes care of loading all the packs.
-- packs is a table of values, which are false if the pack is not loaded yet, and
-- a table of Images if they are.
-- (for now we load everything, we'll care about memory later)

function Drawer:init(w)
	
	self.packs = {}
	self.pdir = "packs"
	self.w = 320
	self.x = LG.getWidth() - self.w
	self.lineh = 20		-- height of the lines in packs list view
	self.imgh = 100		-- size of the squares in pack view
	
	self.view = nil		-- nil when seeing the list of packs, a pack when seeing this pack
	self.items = {}		-- table holding the elements of the current pack as DrawerItems
	
	self.font = LG.newFont(love.default_font, self.lineh)
	
	self.dragw = 10		-- width of the band left of the drawer where you can drag it
	
	self.dragged = false	-- drag stuff
	self.dragx = nil
	
	-- scanning the packs folder (expected to be in the "save directory")
	local ls = LF.enumerate(self.pdir)
	for i,v in ipairs(ls) do
		if LF.isDirectory(self.pdir .. "/" .. v) then
			self:loadpack(v)
		end
	end
	
	--TEMP
	self.view = "basic"
	self:makepackview()
	
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
	
	local hot = math.floor(love.mouse.getY()/self.lineh) + 1
	
	-- background
	LG.setColor(LG.newColor(255,255,255,100))	
	LG.rectangle(love.draw_fill,self.x,0,self.w,LG.getHeight())
	
	-- dragging handle
	if self:isinsidedrag() then
		LG.setColor(LG.newColor(255,255,255,200))
		LG.rectangle(love.draw_fill,self.x,0,self.dragw,LG.getHeight())
	end
	
	-- contents
	LG.setFont(self.font)

	if not self.view then
		local i = 1
		for k,v in pairs(self.packs) do
			if hot == i then
				LG.setColor(LG.newColor(200,0,0))
			else
				LG.setColor(LG.newColor(0,0,0))
			end
			
			LG.draw(k,self.x + 10,i*self.lineh)
			i = i + 1
		end
	else
		for i,v in ipairs(self.items) do
			v:draw()
		end
	end
end

function Drawer:isinside(x,y)
	
	if x >= self.x then
		for i,v in ipairs(self.items) do
			if v:isinside(x,y) then
				return v
			end
		end
		return self
	end
end

function Drawer:isinsidedrag(x)
	local mx = x or love.mouse.getX()
	return mx <= self.x + self.dragw and mx >= self.x
end

function Drawer:makepackview()
	
	local p = self.packs[self.view]
	if not p then return end
	
	-- clean it up first
	self.items = {}
	
	-- how many wide?
	local nw = math.floor(self.w / self.imgh)
	
	local i = 0
	for k,v in pairs(p) do
		local x = i%nw * self.imgh + self.imgh/2 + self.x + self.dragw
		local y = math.floor(i/nw) * self.imgh + self.imgh/2
		local tmp = DrawerItem(x,y,k,v)
		table.insert(self.items,tmp)
		
		i = i + 1
	end
end

function Drawer:mousepressed(x,y,button)
	
	if button == love.mouse_left and self:isinsidedrag(x) then
		self.dragged = true
		self.dragx = x - self.x
	end
end

function Drawer:mousereleased(x,y,button)

	if button == love.mouse_left and self.dragged then
		self.dragged = false
		self.dragx = nil
	end
end

function Drawer:update(dt)

	if self.dragged then
		self.x = love.mouse.getX() - self.dragx
		self.w = LG.getWidth() - self.x
		self:makepackview()
	end
end
