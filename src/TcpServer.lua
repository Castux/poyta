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

require "socket"
require "class"

TcpServer = class()

-- port can be omitted and is chosen by the OS
-- timeout is the timeout for the select function, called at each update
-- 	unnecessary if your server acts only at reception of data or new client
--	defaults to -1 (blocking call)
-- returns nil if no server was established, or the server otherwise

-- a server has following "public" members:
-- server: the actual LuaSocket server socket
-- ip, port: well, ip and port
-- cbconnect, cbrecv, cbdisconnect: callback functions for a new arrival, a new message, and a departure
-- 	(don't set to nil, but to "function() end" instead)


function TcpServer:init(port,timeout)
	local port = port or 0
	self.server = socket.bind("*", port)
	
	if self.server == nil then
		return nil
	end
	
	self.ip, self.port = self.server:getsockname()
	
	self.cbconnect = function(client) end
	self.cbrecv = function(data,client) end
	self.cbdisconnect = function(client) end
	
	self.clients = {}
	self.partials = {}
	
	self.timeout = 0
	self.selecttimeout = timeout or -1
	
	self.server:settimeout(self.timeout)
	
	return self
end

-- this has to be called pretty often...
-- it checks for new clients, accept them automatically
-- also check for new messages from clients, and disconnected clients
-- for each of these events, it calls the appropriate callback
function TcpServer:update()
	
	
	-- check what sockets changed
	local sendt = {}
	local ins = table.insert
	
	ins(sendt,self.server)
	for k,_ in pairs(self.clients) do
		ins(sendt,k)
	end
	
	local ready = socket.select(sendt, nil, self.selecttimeout)
	
	-- check new clients
	if ready[self.server] then
		local client = self.server:accept()
		if client then
		
			-- add to table
			client:settimeout(self.timeout)
			self.clients[client] = true
		
			-- and callback
			self.cbconnect(client)
		else
			-- should never happen
		end
	end
	
	-- check new data and closed connections from clients
	for k,_ in pairs(self.clients) do
	
		if ready[k] then
			local data,err,partial = k:receive()
			if not err then
				-- collect possible previous partial line
				local prev = self.partials[k] or ""
				self.partials[k] = nil
				-- callback
				self.cbrecv(prev .. data,k)
			elseif err == "closed" then
				-- callback
				self.cbdisconnect(k)
				-- and clean internal table
				self:removeclient(k)
			elseif err == "timeout" then
				-- remember partial line
				local prev = self.partials[k] or ""
				self.partials[k] = prev .. partial
			end
		end
	end
end

-- close a client connection and remove it from the list
function TcpServer:removeclient(client)
	
	client:close()
	-- remove from list
	self.clients[client] = nil

end

-- send data to a client
function TcpServer:send(data,client)
	
	-- terminate with a new line
	local data = data
	if string.sub(data,-1) ~= "\n" then data = data .. "\n" end
	
	return client:send(data)
end

-- send data to all clients, except "except" and "except2"
-- except* can be omitted
function TcpServer:broadcast(data, except, except2)
	for k,_ in pairs(self.clients) do
		if k ~= except and k ~= except2 then
			self:send(data,k)
		end
	end
end


-- close all connections and close server
function TcpServer:close()
	
	-- close clients
	for k,_ in pairs(self.clients) do
		self:removeclient(k)
	end
	
	-- close server
	self.server:close()
end
