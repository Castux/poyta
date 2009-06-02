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

require "TcpServer"
require "ClientManager"

--[[ Initialization ]]


-- Alfred the TcpServer

local port = 6666

Alfred = TcpServer(port,1)

if not Alfred then
	print("Could not run server on port " .. port .. ". Exiting.")
	return
end

print("Server up", Alfred.ip .. ":" .. Alfred.port)

-- Oscar the ClientManager

Oscar = ClientManager()

if not Oscar then
	print("Could not build ClientManager. Exiting.")
	return
end


--[[Callbacks for the server]]

Alfred.cbconnect = function(cli)

	if not cli then return end
	
	local ip,port = cli:getpeername()
	
	-- add it
	local tmp = Oscar:add(cli)
	
	-- tell about it
	print("New connection from " .. ip .. ":" .. port)
	io.write("\t")
	Oscar:printclient(cli)
end


--[[Main loop]]

local quit = false

while not quit do

	-- blocking call to the server
	Alfred:update()
	
	-- check if some clients without handshake have expired
	Oscar:checktimeouts()
end
