local FMT = string.format

Supervisor.commands = {

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

}
