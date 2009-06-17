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


--[[ require()'s ]]

package.path = package.path .. ";../common/?.lua"

require "TcpServer"
require "ClientManager"
require "Supervisor"
require "Table"

--[[ Initialization ]]
	-- (singleton classes reuse the name of the class)

-- TcpServer

local port = ... or 6666	-- take first CLI argument as the port

TcpServer = TcpServer(port,1)

if not TcpServer then
	print("Could not run server on port " .. port .. ". Exiting.")
	return
end

print("Server up", TcpServer.ip .. ":" .. TcpServer.port)

-- ClientManager

ClientManager = ClientManager()

if not ClientManager then
	print("Could not build ClientManager. Exiting.")
	return
end

-- Supervisor

Supervisor = Supervisor()

if not Supervisor then
	print("Could not build Supervisor. Exiting.")
	return
end

dofile("commands.lua")

-- Table

Table = Table()

if not Table then
	print("Could not build Table. Exiting.")
	return
end


--[[Callbacks for the server]]

TcpServer.cbconnect = function(cli)

	if not cli then return end
	
	local ip,port = cli:getpeername()
	
	-- add it
	local tmp = ClientManager:add(cli)
	
	-- tell about it
	print("New connection from " .. ip .. ":" .. port)
	io.write("\t")
	ClientManager:printclient(cli)
	
	-- no broadcast is done here. only at handshake
end

TcpServer.cbrecv = function(data,sock)

	print(sock,data)
	Supervisor:parsecommand(data,sock)
end

TcpServer.cbdisconnect = function(sock)
	
	print("Lost connection from " .. ClientManager.clients[sock].nick)
	io.write("\t")
	ClientManager:printclient(sock)
	
	--[[ SERV -> CLIENT ]]
	
	TcpServer:broadcast("LOST " .. ClientManager.clients[sock].nick)
	
	-- and clean
	ClientManager:remove(sock)
end

--[[Main loop]]

local quit = false

while not quit do

	-- blocking call to the server
	TcpServer:update()
	
	-- check if some clients without handshake have expired
	ClientManager:checktimeouts()
end
