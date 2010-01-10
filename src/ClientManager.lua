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

require "common/class"

ClientManager = class()

-- A ClientManager has the following public member:
-- nicks: table which holds the client tables, indexed by nickname

-- client tables have the following public members:
-- clearance, color
-- which can be accessed directly. Changing nick has to be done with ClientManager:changenick().

function ClientManager:init()

	self.nicks = {}
	self.us = nil 	-- points to the client that we are

	--self.widget = nil	-- set by init_gui(). do not set to nil,
				-- it break because initconnection() calls :init()
	
	return self
end

-- add a new client
-- returns the client
-- if us is true, this client is us

function ClientManager:add(nick,clearance,r,g,b,us)

	local tmp = {
		nick = nick,
		clearance = clearance,
		color = {r,g,b},
	}
	
	--shouldnt happen
	if self.nicks[nick] then
		Console:print("[Warning] Adding client with existing nick: " .. nick)
	end
	
	self.nicks[nick] = tmp
	
	if us then
		self.us = tmp
	end
	
	self:updategui()
	
	return tmp
end

-- change the nick of the client oldnick to newnick
-- returns false in case of existing nick (but does the change anyway)

function ClientManager:changenick(oldnick,newnick)
	
	local ret = true
	
	-- shouldn't happen
	if self.nicks[newnick] ~= nil then
		Console:print("[Warning] Changing old nick ".. oldnick
			.. " to existing nick: " .. newnick)
		ret = false
	end
		
	local cli = self.nicks[oldnick]
	
	self.nicks[oldnick] = nil
	self.nicks[newnick] = cli
	cli.nick = newnick
	
	self:updategui()
	
	return ret
end


function ClientManager:printclient(nick)

	local tmp = self.nicks[nick]
	local clear

	if tmp.clearance == 0 then
		clear = "observer"
	elseif tmp.clearance == 1 then
		clear = "voice"
	elseif tmp.clearance == 2 then
		clear = "hand"
	elseif tmp.clearance == 3 then
		clear = "host"
	end
	
	local star = ""
	if nick == self.us.nick then
		star = "*"
	end
	
	return FMT("%s%s (%s)", star, tmp.nick, clear)
end

function ClientManager:updategui()
	
	local tab = {}
	
	for k,v in pairs(self.nicks) do
		tab[#tab + 1] = self:printclient(k)
	end
	
	-- Add to the gui list
	self.widget:Set(tab)
end
