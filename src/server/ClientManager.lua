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

require "class"

ClientManager = class()

-- A ClientManager has the following public member:
-- clients: table which holds the client tables, indexed by socket
-- nicks: table which holds the client tables, indexed by nickname

-- client tables have the following public members:
-- clearance, color
-- which can be accessed directly. Changing nick has to be done with ClientManager:changenick().

function ClientManager:init()

	self.clients = {}
	self.nicks = {}
	
	self.clienttimeout = 5
	
	return self
end

-- add a new client based on socket sock.
-- nick is initialised to the socket as a string, clearance to -1, and a random color
-- returns the client

function ClientManager:add(sock)
	
	local _,_,nick = string.find(tostring(sock), "(%w+)$")
	local tmp = {
		socket = sock,
		nick = nick,
		clearance = -1,
		color = {math.random(0,255),math.random(0,255),math.random(0,255)},
		time = os.time()
	}
	
	self.clients[sock] = tmp
	self.nicks[nick] = tmp
	
	return tmp
end

-- change the nick of the client associated to sock to newnick
-- returns false if impossible (the nick was already taken), true otherwise.

function ClientManager:changenick(sock,newnick)
	
	-- first check if the nick is available
	if self.nicks[newnick] ~= nil then
		return false
	end
		
	local cli = self.clients[sock]
	
	self.nicks[cli.nick] = nil
	self.nicks[newnick] = cli
	cli.nick = newnick
	
	return true	
end

-- change the clearance level of a client, and broadcast about it
-- by is an optional string that gives the nick of the origin of the request
-- defaults to <server>

function ClientManager:promote(cli,level,by)

	local level = level
	local by = by or "<server>"
	
	if level < 0 then level = 0 end
	
	cli.clearance = level
	print("", cli.nick .. " was promoted to level " .. level)
	
	-- SERV -> CLI
		
	local str = string.format("PROMOTE %s %s %d", by, cli.nick, level)
	Alfred:broadcast(str)
end

-- remove client associated to sock from client table
-- returns false if there wasn't such a client, true otherwise.

function ClientManager:remove(sock)
	
	local cli = self.clients[sock]
	
	-- first check if it is here
	if cli == nil then
		return false
	end
	
	self.nicks[cli.nick] = nil
	self.clients[sock] = nil
	
	-- check if a host remains and if not, promote someone from level 2, then 1, then 0.
	if not self:istherehost() then
		for sock,cli in pairs(self.clients) do
			if cli.clearance == 2 then
				self:promote(cli,3)
				return
			end
		end
		
		for sock,cli in pairs(self.clients) do
			if cli.clearance == 1 then
				self:promote(cli,3)
				return
			end
		end
		
		for sock,cli in pairs(self.clients) do
			if cli.clearance == 0 then
				self:promote(cli,3)
				return
			end
		end
	
	end
	
	
	return true
end

function ClientManager:printclient(sock)

	local tmp = self.clients[sock]
	local col = "(" .. tmp.color[1] .. "," .. tmp.color[2] .. "," .. tmp.color[3] .. ")"
	print(tmp.socket, tmp.nick, tmp.clearance, col, tmp.time)
end

function ClientManager:checktimeouts()
	local now = os.time()
	
	for sock,cli in pairs(self.clients) do
		if cli.clearance == -1 and os.difftime(now,cli.time) > self.clienttimeout then
			print("Client did not handshake and expired.")
			io.write("\t")
			self:printclient(sock)
			
			Alfred:removeclient(sock)
			self:remove(sock)
		end
	end
end

function ClientManager:istherehost()
	
	for sock,cli in pairs(self.clients) do
		if cli.clearance == 3 then
			return true
		end
	end
	
	return false
end
