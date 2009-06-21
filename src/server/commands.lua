require "Entity"
require "BasicEntity"

-- to be used by every command that tries to manipulate an entity
-- checks if an id is valid, and if not, warns the original user
local fetch_entity = function(str,sock)
	local cli = ClientManager.clients[sock]
	local id = tonumber(str)
	local e = Table.ids[id]
	
	if not id then
		local err = "Malformed command, entity missing"
		print("",err)
		TcpServer:send("ERROR " .. err, sock)
		return
	end
	
	if not e then
		local err = "Entity " .. id .. " does not exist"
		print("",err)
		TcpServer:send("ERROR " .. err, sock)
		return
	end
	
	return id,e,cli
end

-- Modify the supervisor to check clearance before executing a function

Supervisor.clearances = {

	-- basic user management
	HANDSHAKE = -1,
	NICK = -1,
	COLOR = -1,
	QUIT = -1,
	PING = -1,

	SAY = 1,
	TELL = 1,

	PROMOTE = 2,
	KICK = 3,

	-- entity manipulation
	ENTITY = 2,
	MOVE = 2,
	ROTATE = 2,
	SCALE = 2,
	FLIP = 2,
	DELETE = 2,
	MOVEZ = 2,
	
	-- basic entities
	IMAGE = 2,
	SETCOLOR = 2,
	LABEL = 2,
	SETLABEL = 2,
	ATTACH = 2,
	
}

function Supervisor:parsecommand(data,sock)

	local w = self:split(data)
	
	-- don't treat empty commands
	if w[1] == nil then
		return
	end
	
	local func = self.commands[w[1]]
	
	-- does command exist?
	if not func then
		local err = "Command " .. w[1] .. " unknown"
		print("", err)
		TcpServer:send("ERROR " .. err, sock)
		return
	end
	
	-- is user allowed to call it?
	local cli = ClientManager.clients[sock]
	if cli.clearance < self.clearances[w[1]] then
		local err = cli.nick .. " is not allowed to use command " .. w[1]
		print("", err)
		TcpServer:send("ERROR " .. err, sock)
		return
	end
	
	-- if everything ok, call it
	func(w, sock)
end


Supervisor.commands = {

--[[Basic user management functions]]

HANDSHAKE = function(w,sock)
	local cli = ClientManager.clients[sock]

	if w.orig == "HANDSHAKE Do you want to play a game?" and cli.clearance == -1 then
				
		print("", "Accepted handshake from", sock)
		
		-- promote to host if there is none, or to observer instead
		if not ClientManager:istherehost() then
			ClientManager:promote(cli,3)
		else
			ClientManager:promote(cli,2)
		end
		
		-- SERV -> CLIENT stuff
		
		local str = FMT("CLIENT %s %d %d %d %d", cli.nick, cli.clearance,
			cli.color[1], cli.color[2], cli.color[3])

			-- tell everyone but him
		TcpServer:broadcast(str, sock)
			-- tell him
		TcpServer:send(string.gsub(str, "CLIENT", "YOUARE"), sock)
		
		-- and tell the new one about all the other people
		
		for _,other in pairs(ClientManager.clients) do
			if other ~= cli then
				local str = FMT("THEREIS %s %d %d %d %d", other.nick,
					 other.clearance, other.color[1], other.color[2], other.color[3])
				TcpServer:send(str,sock)
			end
		end
		
		-- and about the gamestate
		
		for id,e in Table:pairs() do
			TcpServer:send(e:dumpstatus("=server=",id),sock)
		end
		
	end
end,

NICK = function(w,sock)

	if not w[2] then return end
	
	local oldnick = ClientManager.clients[sock].nick
	local success = ClientManager:changenick(sock,w[2])
	
	if success then
		print("", oldnick .. " changed their nick to " .. ClientManager.clients[sock].nick)
		-- server -> clients
		if ClientManager.clients[sock].clearance >= 0 then
			TcpServer:broadcast("NICK " .. oldnick .. " " .. ClientManager.clients[sock].nick)
		end
	else
		local err = "Nick " .. w[2] .. " is already in use"
		print("", err)
		-- server -> client
		TcpServer:send("ERROR " .. err, sock)
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
	local color = ClientManager.clients[sock].color
	color[1] = r
	color[2] = g
	color[3] = b
	
	print("", ClientManager.clients[sock].nick .. " changed their color to " .. 
		"(" .. r .. "," .. g .. "," .. b .. ")")
		
	-- SERV -> CLIENT stuff
	
	if ClientManager.clients[sock].clearance >= 0 then
		local str = FMT("COLOR %s %d %d %d", ClientManager.clients[sock].nick, r, g, b)
		TcpServer:broadcast(str)
	end
end,

SAY = function(w,sock)
	local cli = ClientManager.clients[sock]
	
	local message = string.gsub(w.orig, "^SAY%s*", "")
	print("", cli.nick .. " says: " .. message)
	
	-- SERV -> CLIENT stuff
	TcpServer:broadcast("SAY " .. cli.nick .. " " .. message)
end,

TELL = function(w,sock)
	local cli = ClientManager.clients[sock]
	
	if not w[2] then return end
	
	local target = ClientManager.nicks[w[2]]
	if target == nil then
		local err = w[2] .. ": no such nick"
		print("", err)
		
		TcpServer:send("ERROR " .. err, sock)
		return
	end
	
	
	local message = string.gsub(w.orig, "^TELL%s*%w+%s*", "")
	print("", cli.nick .. " tells " .. w[2] .. ": " .. message)
	
	-- SERV -> CLIENT stuff
	local command = FMT("TELL %s %s", cli.nick, w[2])
	
		-- first the two concerned
	TcpServer:send(command .. " " .. message, sock)
	TcpServer:send(command .. " " .. message, target.socket)
		-- then the others
	TcpServer:broadcast(command, sock, target.socket)
end,

QUIT = function(w,sock)
	local nick = ClientManager.clients[sock].nick
	local clear = ClientManager.clients[sock].clearance
	
	print("", nick .. " left")
	
	TcpServer:removeclient(sock)
	ClientManager:remove(sock)
	
	-- SERV -> CLIENT stuff
	if clear >= 0 then
		TcpServer:broadcast("QUIT " .. nick)
	end
end,

PROMOTE = function(w,sock)
	local cli = ClientManager.clients[sock]
	local target = ClientManager.nicks[w[2]]
	local level = tonumber(w[3])
	
	local err = ""
	
	if level == nil then
		err = "Malformed command"
	elseif target == nil then
		err = w[2] .. ": no such nick"
	elseif cli.clearance == 2 and (target.clearance == 3 or level == 3) then
		err = cli.nick .. " is not allowed to promote to/from host"
	end
	
	if err ~= "" then
		TcpServer:send("ERROR " .. err,sock)
		return
	end
	
	ClientManager:promote(target,level,cli.nick)
	
	-- SERV -> CLIENT stuff done in :promote()

end,

KICK = function(w,sock)
	local cli = ClientManager.clients[sock]
	local target = ClientManager.nicks[w[2]]
	
	if not w[2] then return end
	
	if target == nil then
		TcpServer:send("ERROR " ..  w[2] .. ": no such nick",sock)
		return
	end

	print("", cli.nick .. " kicked " .. w[2])
	
	-- SERV -> CLIENT stuff
	TcpServer:broadcast(FMT("KICK %s %s", cli.nick, w[2]))
	
	-- cleaning
	TcpServer:removeclient(target.socket)
	ClientManager:remove(target.socket)
end,

PING = function(w,sock)
	local cli = ClientManager.clients[sock]
	local time = os.time()
	
	print("", "Received PING from " .. cli.nick .. " at " .. time)
	
	-- SERV -> CLIENT stuff
	TcpServer:send("PONG " .. time, sock)
end,



--[[Entities management]]

ENTITY = function(w,sock)
	local cli = ClientManager.clients[sock]
	
	-- make entity and put it on the table
	local id,e = Table:add( Entity(tonumber(w[2]),tonumber(w[3]),tonumber(w[4])) )	
	
	print("", FMT("%s created entity %d at (%d,%d) with angle %d", cli.nick, id, e.x, e.y, e.a))
	
	-- WARN USERS
	TcpServer:broadcast(e:dumpstatus(cli.nick, id))
end,

MOVE = function(w,sock)
	
	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end
	
	-- move it
	e:set(tonumber(w[3]), tonumber(w[4]))
	
	print("", FMT("%s moved entity %d to (%d,%d)", cli.nick, id, e.x, e.y))
	
	-- WARN USERS
	TcpServer:broadcast(FMT("MOVE %s %d %d %d", cli.nick, id, e.x, e.y))
end,

ROTATE = function(w,sock)
	
	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end

	-- rotate it
	e:set(nil,nil,tonumber(w[3]))
	
	print("", FMT("%s rotated entity %d to %f", cli.nick, id, e.a))
	
	-- WARN USERS
	TcpServer:broadcast(FMT("ROTATE %s %d %f", cli.nick, id, e.a))
end,

SCALE = function(w,sock)
	
	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end	

	-- scale it
	e:scale(tonumber(w[3]), tonumber(w[4]))
	
	if e.s2 then
		print("", FMT("%s scaled entity %d to (%f,%f)", cli.nick, id, e.s, e.s2))
		TcpServer:broadcast(FMT("SCALE %s %d %f %f", cli.nick, id, e.s, e.s2))
	else
		print("", FMT("%s scaled entity %d to %f", cli.nick, id, e.s))
		TcpServer:broadcast(FMT("SCALE %s %d %f", cli.nick, id, e.s))
	end
	
end,

FLIP = function(w,sock)
	
	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end	
	
	local rand = (w[3] == "random")
	
	-- flip it if you can
	if e.flip then
		e:flip(rand)
		
		print("", FMT("%s flipped entity %d", cli.nick, id))
		
		local str = FMT("FLIP %s %d", cli.nick, id)
		if rand then
			str = str .. " " .. e.curr
		end
		TcpServer:broadcast(str)
	else
		local err = "Entity " .. id .. " cannot be flipped"
		print("", err)
		-- server -> client
		TcpServer:send("ERROR " .. err, sock)
	end
	
end,

DELETE = function(w,sock)
	
	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end

	-- delete it
	Table:remove(id)
	
	print("", FMT("%s removed entity %d", cli.nick, id))
	
	-- WARN USERS
	TcpServer:broadcast(FMT("DELETE %s %d", cli.nick, id))
end,

MOVEZ = function(w,sock)
	
	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end
	
	local pos = tonumber(w[3])
	if not pos then 
		TcpServer:send("ERROR " ..  w[3] .. ": incorrect position",sock)
		return
	end
	
	-- insert it
	Table:remove(id)
	local count = Table:insert(e, pos)	-- insert and count how many moved up in the process
	
	print("", FMT("%s movez'd entity %d to %d", cli.nick, id, pos))
	
	-- WARN USERS
	TcpServer:broadcast(FMT("MOVEZ %s %d %d %d", cli.nick, id, pos, count))
end,

--[[Basic Entities]]

IMAGE = function(w,sock)
	local cli = ClientManager.clients[sock]
	
	-- gather string arguments
	local N = tonumber(w[5])
	if not N then
		return
	end
	
	local strings = {}
	
	for i = 6,6+N-1 do
		table.insert(strings, w[i])
	end
	
	-- make image
	local tmp = NImage(tonumber(w[2]),tonumber(w[3]),tonumber(w[4]), unpack(strings))
	
	local r = tonumber(w[6+N])
	local g = tonumber(w[7+N])
	local b = tonumber(w[8+N])
	if r or g or b then
		tmp:setcolor(r,g,b)
	end
	
	-- add to table
	local id,e = Table:add(tmp)	
	
	print("", FMT("%s created %d-image %d at (%d,%d) with angle %d", cli.nick, #e.sprites, id, e.x, e.y, e.a))
	
	-- WARN USERS
	TcpServer:broadcast(e:dumpstatus(cli.nick, id))
end,

SETCOLOR = function(w,sock)

	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end
	
	local r = tonumber(w[3])
	local g = tonumber(w[4])
	local b = tonumber(w[5])
	
	e:setcolor(r,g,b)
	
	-- WARN USERS
	TcpServer:broadcast(FMT("SETCOLOR %s %d %d %d %d", cli.nick, id, e.r, e.g, e.b))
end,

LABEL = function(w,sock)
	local cli = ClientManager.clients[sock]
	
	local tmp = Label(tonumber(w[2]),tonumber(w[3]),tonumber(w[4]), w[5] or "%s", w[6] or "%s", tonumber(w[7]))
	
	-- add to table
	local id,e = Table:add(tmp)	
	
	print("", FMT("%s created label %d at (%d,%d) with angle %d", cli.nick, id, e.x, e.y, e.a))
	
	-- WARN USERS
	TcpServer:broadcast(e:dumpstatus(cli.nick, id))
end,

SETLABEL = function(w,sock)

	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end
	
	local str = w[3]
	if not str then str = "%s" end
	
	e.text[e.curr] = str
	
	-- WARN USERS
	TcpServer:broadcast(FMT("SETLABEL %s %d %s", cli.nick, id, e.text[e.curr]))
end,

ATTACH = function(w,sock)

	local id,e,cli = fetch_entity(w[2],sock)
	if not id then return end
	
	if not e:isa(Label) then
		TcpServer:send("ERROR " ..  id .. " is not a label",sock)
		return
	end
	
	local target = tonumber(w[3])
	
	e:attachto(target)
	
	-- WARN USERS
	local str = FMT("ATTACH %s %d", cli.nick, id)
	if target then
		str = str .. " " .. target
	end
	
	TcpServer:broadcast(str)
end,

}

