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

Supervisor = class()


function Supervisor:init()
	
	return self
end

-- splits a string into white separated words
-- returns a table of them, with the original line in the orig field

function Supervisor:split(line)
	local words = {}
	for w in string.gmatch(line, "%S+") do
		table.insert(words, w)
	end
	
	words.orig = line
	
	return words
end

-- the main command interpreter. check if the command exists and then calls the 
-- corresponding function from the command table.

function Supervisor:parsecommand(data,sock)

	print(sock,data)

	local w = self:split(data)
	
	local func = self.commands[w[1]]
		
	if func then
		func(w,sock)
	else
		print("","Command " .. w[1] .. " unknown")
	end
end

--[[Command associated functions]]

Supervisor.commands = {

HANDSHAKE = function(w,sock)
	if w.orig == "HANDSHAKE Do you want to play a game?" and Oscar.clients[sock].clearance == -1 then
		Oscar.clients[sock].clearance = 0
		
		print("", "Accepted handshake from", sock)
		
		-- promote to host if there is none
		if not Oscar:istherehost() then
			Oscar:promote(Oscar.clients[sock],3)
		end
		
		-- SERV -> CLIENT stuff
		
	end
end,

NICK = function(w,sock)
	local oldnick = Oscar.clients[sock].nick
	local success = Oscar:changenick(sock,w[2])
	
	if success then
		print("", oldnick .. " changed their nick to " .. Oscar.clients[sock].nick)
	else
		print("", "Nick " .. w[2] .. " is already in use")
	end
	
	-- SERV -> CLIENT stuff
end,

COLOR = function(w,sock)
	local r,g,b = tonumber(w[2]) or 0, tonumber(w[3]) or 0, tonumber(w[4]) or 0
	
	-- boundaries check
	if r > 255 then r = 255 end
	if g > 255 then g = 255 end
	if b > 255 then b = 255 end	
	
	if r < 0 then r = 0 end
	if g < 0 then g = 0 end
	if b < 0 then b = 0 end
	
	-- update
	local color = Oscar.clients[sock].color
	color[1] = r
	color[2] = g
	color[3] = b
	
	print("", Oscar.clients[sock].nick .. " changed their color to " .. 
		"(" .. r .. "," .. g .. "," .. b .. ")")
		
	-- SERV -> CLIENT stuff
end,

SAY = function(w,sock)
	local cli = Oscar.clients[sock]
	
	if cli.clearance < 1 then
		print("", cli.nick .. " is not allowed to speak")
		return
	end
	
	print("", cli.nick .. " says: " .. string.gsub(w.orig, "^SAY%s*", ""))
	
	-- SERV -> CLIENT stuff
end,

TELL = function(w,sock)
	local cli = Oscar.clients[sock]
	
	if cli.clearance < 1 then
		print("", cli.nick .. " is not allowed to speak")
		return
	end
	
	if Oscar.nicks[w[2]] == nil then
		print("", w[2] .. ": no such nick")
		return
	end
	
	print("", cli.nick .. " tells " .. w[2] .. ": " .. string.gsub(w.orig, "^TELL%s*%w+%s*", ""))
	
	-- SERV -> CLIENT stuff
end,

QUIT = function(w,sock)
	local cli = Oscar.clients[sock]
	
	print("", cli.nick .. " left")
	
	Alfred:removeclient(sock)
	Oscar:remove(sock)
	
	-- SERV -> CLIENT stuff
end,

PROMOTE = function(w,sock)
	local cli = Oscar.clients[sock]
	local target = Oscar.nicks[w[2]]
	local level = tonumber(w[3])
	
	if level == nil then
		print("", "Malformed command")
		return
	end
	
	if cli.clearance < 2 then
		print("", cli.nick .. " is not allowed to change clearance levels")
		return
	end
	
	if target == nil then
		print("", w[2] .. ": no such nick")
		return
	end
	
	if cli.clearance == 2 and (target.clearance == 3 or level == 3) then
		print("", cli.nick .. " is not allowed to promote to/from host")
		return
	end
	
	Oscar:promote(target,level)
	
	-- SERV -> CLIENT stuff
end,

KICK = function(w,sock)
	local cli = Oscar.clients[sock]
	local target = Oscar.nicks[w[2]]
	
	if cli.clearance < 3 then
		print("", cli.nick .. " is not allowed to kick users")
		return
	end
	
	if target == nil then
		print("", w[2] .. ": no such nick")
		return
	end

	print("", cli.nick .. " kicked " .. w[2])
	
	Alfred:removeclient(target.socket)
	Oscar:remove(target.socket)
	
	-- SERV -> CLIENT stuff
	
end,

PING = function(w,sock)
	local cli = Oscar.clients[sock]
	local time = os.time()
	
	print("", "Received PING from " .. cli.nick .. " at " .. time)
	
	-- SERV -> CLIENT stuff
end

}

