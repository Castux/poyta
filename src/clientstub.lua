require "socket"

s = socket.connect("localhost",6666)

function S(str)
	s:send(str .. "\n")
end

S("HANDSHAKE Do you want to play a game?")

S("NICK Toto")
S("NICK Tata")

S("COLOR 200 100 100")
S("COLOR 355 -12 3")
S("COLOR 200 0 1000")

S("SAY Salut tout le monde")
S("SAY  	 Coucou")

--while true do end
