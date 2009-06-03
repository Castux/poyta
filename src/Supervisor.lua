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
	
	-- don't treat empty commands
	if w[1] == nil then
		return
	end
	
	local func = self.commands[w[1]]
		
	if func then
		func(w,sock)
	else
		local err = "Command " .. w[1] .. " unknown"
		print("", err)
		Alfred:send("ERROR " .. err, sock)
	end
end

--[[Command associated functions]]

Supervisor.commands = {

HANDSHAKE = function(w,sock)
	local cli = Oscar.clients[sock]

	if w.orig == "HANDSHAKE Do you want to play a game?" and cli.clearance == -1 then
		cli.clearance = 0
		
		print("", "Accepted handshake from", sock)
		
		-- promote to host if there is none
		if not Oscar:istherehost() then
			Oscar:promote(cli,3)
		end
		
		-- SERV -> CLIENT stuff
		
		local str = string.format("CLIENT %s %d %d %d %d", cli.nick, cli.clearance,
			cli.color[1], cli.color[2], cli.color[3])

			-- tell everyone but him
		Alfred:broadcast(str, sock)
			-- tell him
		Alfred:send(string.gsub(str, "CLIENT", "YOUARE"), sock)
		
		-- and tell the new one about all the other people [later: gamestate too]
		
		for _,other in pairs(Oscar.clients) do
			if other ~= cli then
				local str = string.format("CLIENT %s %d %d %d %d", other.nick,
					 other.clearance, other.color[1], other.color[2], other.color[3])
				Alfred:send(str,sock)
			end
		end
	end
end,

NICK = function(w,sock)
	local oldnick = Oscar.clients[sock].nick
	local success = Oscar:changenick(sock,w[2])
	
	if success then
		print("", oldnick .. " changed their nick to " .. Oscar.clients[sock].nick)
		-- server -> clients
		Alfred:broadcast("NICK " .. oldnick .. " " .. Oscar.clients[sock].nick)
	else
		local err = "Nick " .. w[2] .. " is already in use"
		print("", err)
		-- server -> client
		Alfred:send("ERROR " .. err, sock)
	end
	
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
	
	local str = string.format("COLOR %s %d %d %d", Oscar.clients[sock].nick, r, g, b)
	Alfred:broadcast(str)
end,

SAY = function(w,sock)
	local cli = Oscar.clients[sock]
	
	if cli.clearance < 1 then
		local err = cli.nick .. " is not allowed to speak"
		print("", err)
		
		Alfred:send("ERROR " .. err, sock)
		return
	end
	
	local message = string.gsub(w.orig, "^SAY%s*", "")
	print("", cli.nick .. " says: " .. message)
	
	-- SERV -> CLIENT stuff
	Alfred:broadcast("SAY " .. cli.nick .. " " .. message)
end,

TELL = function(w,sock)
	local cli = Oscar.clients[sock]
	
	if cli.clearance < 1 then
		local err = cli.nick .. " is not allowed to speak"
		print("", err)
		
		Alfred:send("ERROR " .. err, sock)
		return
	end
	
	local target = Oscar.nicks[w[2]]
	if target == nil then
		local err = w[2] .. ": no such nick"
		print("", err)
		
		Alfred:send("ERROR " .. err, sock)
		return
	end
	
	
	local message = string.gsub(w.orig, "^TELL%s*%w+%s*", "")
	print("", cli.nick .. " tells " .. w[2] .. ": " .. message)
	
	-- SERV -> CLIENT stuff
	local command = string.format("TELL %s %s", cli.nick, w[2])
	
		-- first the two concerned
	Alfred:send(command .. " " .. message, sock)
	Alfred:send(command .. " " .. message, target.socket)
		-- then the others
	Alfred:broadcast(command, sock, target.socket)
end,

QUIT = function(w,sock)
	local nick = Oscar.clients[sock].nick
	
	print("", nick .. " left")
	
	Alfred:removeclient(sock)
	Oscar:remove(sock)
	
	-- SERV -> CLIENT stuff
	Alfred:broadcast("QUIT " .. nick)
end,

PROMOTE = function(w,sock)
	local cli = Oscar.clients[sock]
	local target = Oscar.nicks[w[2]]
	local level = tonumber(w[3])
	
	local err = ""
	
	if level == nil then
		err = "Malformed command"
	elseif cli.clearance < 2 then
		err = cli.nick .. " is not allowed to change clearance levels"
	elseif target == nil then
		err = w[2] .. ": no such nick"
	elseif cli.clearance == 2 and (target.clearance == 3 or level == 3) then
		err = cli.nick .. " is not allowed to promote to/from host"
	end
	
	if err ~= "" then
		Alfred:send("ERROR " .. err,sock)
		return
	end
	
	Oscar:promote(target,level,cli.nick)
	
	-- SERV -> CLIENT stuff done in :promote()

end,

KICK = function(w,sock)
	local cli = Oscar.clients[sock]
	local target = Oscar.nicks[w[2]]
	
	local err = ""
	
	if cli.clearance < 3 then
		err = cli.nick .. " is not allowed to kick users"
	elseif target == nil then
		err = w[2] .. ": no such nick"
	end

	if err ~= "" then
		Alfred:send("ERROR " .. err,sock)
		return
	end
	
	print("", cli.nick .. " kicked " .. w[2])
	
	Alfred:removeclient(target.socket)
	Oscar:remove(target.socket)
	
	-- SERV -> CLIENT stuff
	Alfred:broadcast(string.format("KICK %s %s", cli.nick, w[2]))
end,

PING = function(w,sock)
	local cli = Oscar.clients[sock]
	local time = os.time()
	
	print("", "Received PING from " .. cli.nick .. " at " .. time)
	
	-- SERV -> CLIENT stuff
	Alfred:send("PONG " .. time, sock)
end

}

