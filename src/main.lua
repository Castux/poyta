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


-- client specific includes
love.filesystem.require("Console.lua")
love.filesystem.require("TcpClient.lua")
love.filesystem.require("ClientManager.lua")
love.filesystem.require("Table.lua")
love.filesystem.require("EventHandler.lua")
love.filesystem.require("Drawer.lua")

-- common includes. must override Lua's require and take care of dependencies by hand
-- because of Löve's integration.
-- (since these are used by the pure Lua server also, we can't put Löve's require in them)

require = function() end

love.filesystem.require("common/Supervisor.lua")
love.filesystem.require("Entity.lua")

-- shortcuts
LG = love.graphics
FMT = string.format
LF = love.filesystem

--[[ THE REAL THING ]]

function load()
	

	-- all singleton classes reuse the class name
	--	MyClass = MyClass(init params)
	
	-- console
	Console = Console(4,4,80,10,"VeraMono.ttf",12)
	Console.callback = function(self,line)
		TcpClient:send(line)
	end
		
	-- network
	TcpClient = TcpClient("localhost",6666,0)
	if not TcpClient.socket then
		Console:print("Impossible to connect to server")
	else
		Console:print("Connected to server ".. TcpClient.ip .. ":" .. TcpClient.port)
	end
	
	-- supervisor
	Supervisor = Supervisor()
	love.filesystem.include("commands.lua")
	
	-- clientmanager
	ClientManager = ClientManager()
	
	-- table
	Table = Table()

	-- drawer
	Drawer = Drawer()

	-- event handler
	EventHandler = EventHandler()
	EventHandler:register(GlobalEvents)
	EventHandler:register(Console)
	EventHandler:register(Drawer)
	EventHandler:register(Table)
	
	-- pluging things together: network callbacks
	TcpClient.cbrecv = function(line)
		
		local success,w = Supervisor:parsecommand(line)
		if not success then
			Console:print("[recv unknown cmd]" .. w.orig)
		end
		
		-- later, all commands will go to a hidden console,
		-- since every command will have repercussions in game/chat
	end
	TcpClient.cbdisconnect = function()
		Console:print("Disconnected from server")
	end
	
	-- tell the server about us
	TcpClient:send("NICK Alfredo")
	TcpClient:send("HANDSHAKE Do you want to play a game?")
	
	TcpClient:send("ENTITY 10 40 10")
	
	-- graphics
	love.graphics.setBackgroundColor(LG.newColor(10,255,10))

	-- love.system.exit()
end

function update(dt)
	
	-- check network input
	TcpClient:update(dt)
	
	-- update stuff on the table
	Table:update(dt)
	
	-- take care of hotness
	EventHandler:update(dt)
	

end

function draw()
	
	Table:draw()
	
	LG.draw(love.timer.getFPS(),600,20)
	Console:draw()
	ClientManager:draw(0,300)
	Drawer:draw()
end

-- a table of priority events

GlobalEvents = {}
function GlobalEvents:keypressed(key)
	
	-- intercept these events
	
	if key == love.key_escape then
		love.system.exit()
		return
	elseif key == love.key_f1 then
		love.system.restart()
		return
	end
	
	-- forward the others
	
	return key
end
