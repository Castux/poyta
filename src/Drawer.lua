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

-- it has two views, the list of packs, of the contents of a pack.
-- it can be resized by dragging the left-end handle, or folded by clicking it

function Drawer:init(w)
	
	self.packs = {}
	self.pdir = "packs"
	self.w = 320		-- width
	self.x = LG.getWidth() - self.w	-- left border
	
	self.lineh = 20		-- height of the lines in packs list view
	self.imgh = 100		-- size of the squares in pack view
	
	self.view = nil		-- nil when seeing the list of packs, a pack name when seeing this pack
	self.items = {}		-- table holding the elements of the current pack as DrawerItems
		
	self.dragw = 16		-- width of the band left of the drawer where you can drag it
	
	self.dragged = false	-- drag stuff
	self.dragx = nil	-- click position when started dragging
	
	self.folded = false	-- folding stuff
	self.oldw = nil		-- width before folding
	
	self.scrolling = false	-- do we need a scroll bar?
	self.totalh = 0		-- summed height of all items
	self.hratio = 0		-- totalh / getHeight()
	self.camy = 0		-- camera shift (value of the top pixel in the drawer's variable view)
	self.scrolled = false	-- is the user actually scrolling the view now?
	
	-- scanning the packs folder (expected to be in the "save directory")
	local ls = LF.enumerate(self.pdir)
	for i,v in ipairs(ls) do
		if LF.isDirectory(self.pdir .. "/" .. v) then
			self:loadpack(v)
		end
	end
	
	-- load some data
	self.defaultsprite = LG.newImage("default.png")
	self.font = LG.newFont(love.default_font, self.lineh)
	
	-- create the items in the view for the first time
	-- (then it's updated each time the drawer is resized or the view is changed)
	self:makepackview()
	
	return self
end

-- for now, loadpack() just loads all the sprites in the folder and adds them
-- the the pack's table

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
	
	-- dragging handle when it's hot
	if self:isinsidedrag() then
		LG.setColor(LG.newColor(255,255,255,200))
		LG.rectangle(love.draw_fill,self.x,0,self.dragw,LG.getHeight())
	end
	
	-- contents (only if unfolded...)
	if self.folded then return end
	
	for i,v in ipairs(self.items) do
		v:draw()
	end
	
	-- scrolling bar
	-- we map 0..totalh to 0..getHeight()
	-- and window size is camy..camy+getHeight()
	local margin = 3
	
	if self.scrolling then
		-- bar
		LG.setColor(LG.newColor(255,255,255))
		LG.rectangle(love.draw_fill, LG.getWidth() - self.dragw, 0, self.dragw, LG.getHeight())
		
		-- indicator
		LG.setColor(LG.newColor(100,100,100))
		
		LG.rectangle(love.draw_fill, 
			LG.getWidth() - self.dragw + margin, self.camy * self.hratio + margin, 
			self.dragw - 2*margin, LG.getHeight() * self.hratio - 2*margin)
	end
end

-- needed by EventHandler. returns the hot object
function Drawer:isinside(x,y)
	
	if x >= self.x then
	
		-- check drag bar
		if x >= LG.getWidth() - self.dragw then
			return self
		end
		
		-- check items
		for i,v in ipairs(self.items) do
			if v:isinside(x,y) then
				return v
			end
		end
		
		-- all is left is the drawer it self
		return self
	end
end

-- can take an argument x, but defaults to mouse's current x position
-- returns a boolean
function Drawer:isinsidedrag(x)
	local mx = x or love.mouse.getX()
	return mx <= self.x + self.dragw and mx >= self.x
end

function Drawer:isinsidescroll(x)
	local mx = x or love.mouse.getX()
	return mx >= LG.getWidth() - self.dragw and self.scrolling
end

-- fills the self.items table with DrawerItems placed correctly in the drawer
function Drawer:makepackview()
	
	local p = self.packs[self.view]
	
	-- clean it up first
	self.items = {}
	
	-- in pack view
	if p then
		-- make title first
		table.insert(self.items,DrawerTextItem(self.x + self.dragw, self.lineh, self.view) )
		
		-- how many wide?
		local nw = math.floor( (self.w - self.dragw) / self.imgh)
	
		local i = 0
		for k,v in pairs(p) do
			local x = i%nw * self.imgh + self.imgh/2 + self.x + self.dragw
			local y = math.floor(i/nw) * self.imgh + self.imgh/2 + self.lineh
			local tmp = DrawerItem(x,y,k,v)
			table.insert(self.items,tmp)
		
			i = i + 1
		end
		
		self.totalh = self.lineh + math.ceil( i/nw ) * self.imgh
		
	-- in pack list view
	else
		local i = 1
		for k,v in pairs(self.packs) do
			table.insert(self.items, DrawerTextItem(self.x + self.dragw, i*self.lineh, k) )
			i = i + 1
		end
		
		self.totalh = (i-1)*self.lineh
	end
	
	-- update scroll view
	local oldratio = self.hratio
	local oldy = self.camy + LG.getHeight()/2	-- middle of the view
	oldy = oldy * self.hratio			-- converted to "scrollbar space"
	
	self.hratio = LG.getHeight() / self.totalh
	self.scrolling = self.hratio < 1
	if self.scrolling and oldratio < 1 then
		self:scroll(oldy)
	else
		self.camy = 0
	end
end

function Drawer:mousepressed(x,y,button)
	
	-- forward to items first
	for i,v in ipairs(self.items) do
		v:mousepressed(x,y,button)	
	end
	
	-- unfold if necessary
	if button == love.mouse_left and self:isinsidedrag(x) and self.folded then
		self:switchfold()
		return
	
	-- drag the drawer
	elseif button == love.mouse_left and self:isinsidedrag(x) then
		self.dragged = true
		self.dragx = x - self.x
		self.clickx = x
		self.clicky = y
				
		return
	
	-- scroll the view
	elseif button == love.mouse_left and self:isinsidescroll(x) then
		self.scrolled = true
		self:scroll(y)
	
	end
	
	-- forward if we're not interested
	if not self:isinside(love.mouse.getX(),love.mouse.getY()) then
		return x,y,button
	end
end

function Drawer:mousereleased(x,y,button)

	if button == love.mouse_left and self.dragged then
		-- stop dragging
		self.dragged = false
		self.dragx = nil
		
		-- if it was just a click, fold/unfold the drawer
		if x == self.clickx and y == self.clicky then
			self:switchfold()
		end
	elseif button == love.mouse_left and self.scrolled then
		-- stop scrolling
		self.scrolled = false
	end
	
	-- forward
	return x,y,button
end

-- folds or unfolds the drawer.
-- we don't need to recompute the contents, since unfolding will put everything back in place
function Drawer:switchfold()

	if not self.folded then
		self.folded = true
		self.oldw = self.w
		
		self.w = self.dragw
		self.x = LG.getWidth() - self.w
	else
		self.folded = false
		
		self.w = self.oldw
		self.x = LG.getWidth() - self.w
	end
end

function Drawer:update(dt)
	
	-- take care of dragging
	if self.dragged then
		self.x = love.mouse.getX() - self.dragx
		
		-- avoid having empty drawer by having a maximum value for self.x
		if self.x > LG.getWidth() - self.imgh - self.dragw then
			self.x = LG.getWidth() - self.imgh - self.dragw
		end
		
		self.w = LG.getWidth() - self.x
		self:makepackview()
	
	-- and scrolling
	elseif self.scrolled then
		self:scroll(love.mouse.getY())
	end
end

-- changes the view to pack of name "p", or the pack list if nil
function Drawer:changeview(p)

	self.view = p
	self:makepackview()
end

-- changes scroll value, where y is in pixel
function Drawer:scroll(y)
	
	-- consider the click point the middle of the target zone
	local y = y / self.hratio
	
	y = y - LG.getHeight()/2
	
	-- clip
	if y < 0 then 
		y = 0
	elseif y + LG.getHeight() > self.totalh then
		y = self.totalh - LG.getHeight()
	end
	
	self.camy = y
end

-- returns the Image associated with the string "pack/filename",
-- or the default "not found" sprite.
function Drawer:resolvename(s)
	
	local _,_,pack,name = string.find(s, "(.+)/(.+)")
	
	local p = self.packs[pack]
	if not p then return end
	
	local i = p[name]
	if not i then
		i = self.defaultsprite
	end
	
	return i
end
