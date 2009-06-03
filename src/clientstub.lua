require "socket"

s = socket.connect("localhost",6666)

function S(str)
	s:send(str .. "\n")
end


S("NICK Toto")
S("COLOR 200 100 100")

S("HANDSHAKE Do you want to play a game?")


S("NICK Tata")

S("COLOR 355 -12 3")
S("COLOR 200 0 1000")

S("SAY Salut tout le monde")
S("SAY  	 Coucou")
S("TELL Tata 		 Coucou, ça va biloute ?")

S("PROMOTE Hubert 3")
S("PROMOTE Tata youou")
S("PROMOTE Tata 2")
S("PROMOTE Tata 3")
S("PROMOTE Tata 1")

S("QUIT")

-- reconnect 

os.execute("sleep 1")

s = socket.connect("localhost",6666)
S("HANDSHAKE Do you want to play a game?")

S("NICK Tata")

S("PING")

--S("KICK Tata")

--S("QUIT")

