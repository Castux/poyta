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

-- common includes. must override Lua's require and take care of dependencies by hand
-- because of Löve's integration.
-- (since these are used by the pure Lua server also, we can't put Löve's require in them)

require = function() end

love.filesystem.require("common/Supervisor.lua")
love.filesystem.require("Entity.lua")

-- shortcut
local LG = love.graphics


--[[ THE REAL THING ]]

function load()
	

	-- all singleton classes reuse the class name
	--	MyClass = MyClass(init params)
	
	-- console
	Console = Console(80,24,"VeraMono.ttf",12)
	Console.callback = function(self,line)
		TcpClient:send(line)
	end
	
	LG.setColor(LG.newColor(0,0,150))
	
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
	
	-- pluging things together
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
	
	
	
	-- graphics
	love.graphics.setBackgroundColor(LG.newColor(255,255,255))


	
end

function update(dt)
	
	-- check network input
	TcpClient:update()
	
	-- update stuff
	Table:update()
end

function draw()
	
	Table:draw()
	
	LG.draw(love.timer.getFPS(),600,20)
	Console:draw()
	ClientManager:draw(0,300)
	
end

function keypressed(key)

	if key == love.key_escape then
		love.system.exit()
	
	elseif key == love.key_f1 then
		love.system.restart()
	end
	
	-- forward to console
	Console:input(key)
end
