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

love.filesystem.require("console.lua")
love.filesystem.require("TcpClient.lua")

local LG = love.graphics

function load()
	
	-- console
	cons = Console(80,24,"VeraMono.ttf",12)
	cons.callback = function(self,line)
		Spiderman:send(line)
	end
	
	LG.setColor(LG.newColor(0,0,150))
	
	-- network
	Spiderman = TcpClient("localhost",6666,0)
	if not Spiderman.socket then
		cons:print("Impossible to connect to server")
	end
	
	Spiderman.cbrecv = function(line)
		cons:print(line)
	end
	Spiderman.cbdisconnect = function()
		cons:print("Disconnected from server")
	end
	
	Spiderman:send("HANDSHAKE Do you want to play a game?")
	
	-- graphics
	love.graphics.setBackgroundColor(LG.newColor(255,255,255))


	
end

function update(dt)
	
	-- check network input
	Spiderman:update()
end

function draw()

	LG.draw(love.timer.getFPS(),600,20)
	cons:draw()
end

function keypressed(key)

	if key == love.key_escape then
		love.system.exit()
		
	elseif key == love.key_f1 then
		load()
		return
	end
	
	-- forward to console
	cons:input(key)
end
