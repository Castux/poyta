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

require "Console"
require "TcpClient"
require "ClientManager"
require "Table"
require "EventHandler"
require "Drawer"
require "Menu"
require "TextInput"

require "colorpicker"
require "text_input"

require "common/Supervisor"
require "Entity"
require "BasicEntity"

require "wxluagl"


--[[ THE REAL THING ]]

function load()
	

	-- all singleton classes reuse the class name
	--	MyClass = MyClass(init params)
		
	-- network
	TcpClient = TcpClient()
	
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
		reset()
	end
	
	-- supervisor
	Supervisor = Supervisor()
	dofile "commands.lua"
	
	-- clientmanager
	ClientManager = ClientManager()
	
	-- table
	Table = Table()

	-- drawer
	--Drawer = Drawer()
	
	-- contextual menu
	--Menu = Menu()
	
	-- text input
	--TextInput = TextInput()
	--TextInput.active = false
	
	-- event handler
	EventHandler = EventHandler()
	EventHandler:register(GlobalEvents)
	EventHandler:register(TextInput)
	EventHandler:register(Menu)
	EventHandler:register(Drawer)
	EventHandler:register(Console)
	EventHandler:register(Table)
	
	-- graphics
	--LG.setBackgroundColor(LG.newColor(240,240,240))
	
	-- some more sprite loading
	--dofile "uisprites.lua"
	
	-- console
	Console = Console()
	
	-- console sends directly everything that looks like a command, and SAYs the rest
	Console.callback = function(self,line)
		local word = string.match(line,"^(%w+)")
		if Supervisor.commands[word] then
			TcpClient:send(line)
		else
			TcpClient:send("SAY " .. line)
		end
		
		-- temp
		Console:print(line)
	end
	
	-- Init GUI (There cannot be other function calls after this)
	init_gui()
end

function reset()

	TcpClient:close()
	ClientManager:init()
	Table:init()
end

function update(dt)
	
	-- check network input
	TcpClient:update(dt)
	
	-- update stuff on the table
	Table:update(dt)
	
	-- take care of hotness
	EventHandler:update(dt)
	
	-- drawer can haz update too
	Drawer:update(dt)
	

end

function draw()
	
	Table:draw()
	
	-- LG.draw(love.timer.getFPS(),600,20)
	Console:draw()
	ClientManager:draw(4,134)
	Drawer:draw()
	Menu:draw()
	TextInput:draw()
end

-- a table of top priority events

GlobalEvents = {}
function GlobalEvents:keypressed(key)
	
	local key = key
	
	-- intercept these events
	if key == love.key_escape then
		love.system.exit()
		return
	elseif key == love.key_f1 then
		love.system.restart()
		return
		
	-- convert page up/down into wheel up/down (for compatibility with crappy mice)
	elseif key == love.key_pageup then
		EventHandler:treatevent{"mdown",love.mouse.getX(),love.mouse.getY(),love.mouse_wheelup}
		return
	elseif key == love.key_pagedown then
		EventHandler:treatevent{"mdown",love.mouse.getX(),love.mouse.getY(),love.mouse_wheeldown}
		return
	end
	
	-- forward the others
	return key
end

function GlobalEvents:mousepressed(x,y,button)

	-- convert ctrl-click to right-click
	if button == love.mouse_left and ( love.keyboard.isDown(love.key_lctrl) or
		love.keyboard.isDown(love.key_rctrl) ) then
		
		return x,y,love.mouse_right
	end
	
	-- forward all the rest
	return x,y,button
end

function initconnection(host,port)
	
	local host = host or "localhost"
	local port = port or 6666
	
	reset()
	
	TcpClient:connect(host,port)
	
	if not TcpClient.socket then
		Console:print("Impossible to connect to server " .. host .. ":" .. port)
	else
		Console:print("Connected to server ".. TcpClient.ip .. ":" .. TcpClient.port)
	end

	TcpClient:send("HANDSHAKE Do you want to play a game?")
end

load()
