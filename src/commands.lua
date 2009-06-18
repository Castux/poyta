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


-- a shortcut function to get id and entity
function fetch_entity(str)
	local id = tonumber(str)
	local e = Table.ids[id]
	if not e then
		Console:print("[Warning] Entity " .. str .. " does not exist. We are not in sync with server...")
		return
	else
		return id,e
	end
end



Supervisor.commands = {

--[[Users management]]

CLIENT = function(w)
	ClientManager:add(w[2], w[3], w[4], w[5], w[6])
	Console:print(w[2] .. " joined")
end,

YOUARE = function(w)
	ClientManager:add(w[2], w[3], w[4], w[5], w[6])
	ClientManager.us = ClientManager.nicks[w[2]]
end,

THEREIS = function(w)
	ClientManager:add(w[2], w[3], w[4], w[5], w[6])
end,

NICK = function(w)
	ClientManager:changenick(w[2], w[3])
	Console:print(w[2] .. " is now known as " .. w[3])
end,

COLOR = function(w)
	local color = ClientManager.nicks[w[2]].color
	color[1] = w[3]
	color[2] = w[4]
	color[3] = w[5]
	
	color = FMT("%d,%d,%d",w[3],w[4],w[5])
	Console:print(w[2] .. " changed color to " .. color)
end,

SAY = function(w)
	local message = string.gsub(w.orig, "^SAY%s*%w+%s*", "")
	Console:print(FMT("<%s> %s",w[2], message))
end,

TELL = function(w)
	if w[4] then
		local message = string.gsub(w.orig, "^TELL%s*%w+%s*%w+%s*", "")
		Console:print(FMT("*%s->%s* %s",w[2],w[3],message))
	else
		Console:print(FMT("*%s whispers to %s*",w[2],w[3]))
	end
end,

QUIT = function(w)
	ClientManager.nicks[w[2]] = nil
	Console:print(w[2] .. " left")
end,

LOST = function(w)
	ClientManager.nicks[w[2]] = nil
	Console:print("Lost connection from " .. w[2])
end,

PROMOTE = function(w)
	ClientManager.nicks[w[3]].clearance = tonumber(w[4])
	Console:print(FMT("%s set %s to clearance level %s",w[2],w[3],w[4]))
end,

KICK = function(w)
	ClientManager.nicks[w[3]] = nil
	Console:print(FMT("%s kicked %s",w[2],w[3]))
end,

--[[Basic entities manipulation]]

ENTITY = function(w)
	local tmp = Entity(tonumber(w[4]),tonumber(w[5]),tonumber(w[6]))
	tmp:initview()
	
	Table:add(tonumber(w[3]), tmp)
	Console:print(FMT("%s added an entity",w[2]))
end,

MOVE = function(w)
	local id,e = fetch_entity(w[3])
	if not e then return end

	e:set(tonumber(w[4]),tonumber(w[5]))	
end,

ROTATE = function(w)
	local id,e = fetch_entity(w[3])
	if not e then return end

	e:set(nil,nil,tonumber(w[4]))	
end,

SCALE = function(w)
	local id,e = fetch_entity(w[3])
	if not e then return end

	e:scale(tonumber(w[4]),tonumber(w[5]))
end,

DELETE = function(w)
	local id,e = fetch_entity(w[3])
	if not e then return end

	Table:remove(id)	
end,

MOVEZ = function(w)
	local id,e = fetch_entity(w[3])
	if not e then return end

	Table:remove(id)
	Table:insert(e,tonumber(w[4]),tonumber(w[5]))
end,
--[[Basic entities]]

IMAGE = function(w)

	-- gather strings
	local N = tonumber(w[7])
	local strings = {}
	
	for i = 8,8+N-1 do
		local s = TcpClient:unescapestring(w[i])
		table.insert(strings, s)
	end
	
	local tmp = NImage(tonumber(w[4]),tonumber(w[5]),tonumber(w[6]), unpack(strings))
	tmp:setcolor(tonumber(w[8+N]),tonumber(w[9+N]),tonumber(w[10+N]))
	
	tmp:initview()
	
	-- add to table
	Table:add(tonumber(w[3]), tmp)
end,

SETCOLOR = function(w)
	
	local id,e = fetch_entity(w[3])
	if not e then return end

	e:setcolor(tonumber(w[4]),tonumber(w[5]),tonumber(w[6]))
end,

}
