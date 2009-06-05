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
love.filesystem.require("common/class.lua")

TcpClient = class()

-- timeout is the timeout for the select function, called at each update
--	defaults to -1 (blocking call)

-- ip, port: well, ip and port or the distant host
-- cbrecv, cbdisconnect: callback functions for a new message, and loss of connection
-- 	(don't set to nil, but to "function() end" instead)

-- the object can be without a connection, before a call to connect(), after a call to close() or if disconnected.
-- in this case, self.socket is nil, and calling functions return immediately

function TcpClient:init(host,port,timeout)
	
	self.cbrecv = function(data) end
	self.cbdisconnect = function() end
	
	self.partials = ""
	
	self.timeout = timeout or 0
	
	if host and port then
		self:connect(host,port)
	end
	
	return self
end

function TcpClient:connect(host,port)
	
	self.socket = socket.connect(host,port)
	
	if not self.socket then
		return false
	end
	
	self.ip, self.port = self.socket:getsockname()
	self.socket:settimeout(self.timeout)
	
	return true
end

-- this has to be called pretty often...
-- checks for new messages, and disconnection
-- for each of these events, it calls the appropriate callback
function TcpClient:update()
	
	if not self.socket then return end
	
	-- check new data and closed connections from clients
	local data,err,partial = self.socket:receive()
	if not err then
		-- collect possible previous partial line
		local prev = self.partial or ""
		self.partials = nil
		-- callback
		self.cbrecv(prev .. data)
	elseif err == "closed" then
		-- callback
		self.cbdisconnect()
		self.socket = nil
	elseif err == "timeout" then
		-- remember partial line
		local prev = self.partial or ""
		self.partial = prev .. partial
	end
end

-- send a line
function TcpClient:send(data)
	
	if not self.socket then return end
	
	-- terminate with a new line
	local data = data
	if string.sub(data,-1) ~= "\n" then data = data .. "\n" end
	
	return self.socket:send(data)
end

-- close connection
function TcpClient:close()
	
	if not self.socket then return end
	
	-- close server
	self.socket:close()
end
