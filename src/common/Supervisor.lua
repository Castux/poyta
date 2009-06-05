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

-- the supervisor is mainly a command parser
-- the command table is indexed by command strings, and contains functions of the form:

-- function(w, ...) end, where w is the table of parsed words and ... is any additional
-- parameters passed to :parsecommand(data, ...)

function Supervisor:init(commands)
	
	self.commands = commands or {}
	
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
-- return true if the command is found.
-- otherwise returns false and the table of parsed words

function Supervisor:parsecommand(data, ...)

	local w = self:split(data)
	
	-- don't treat empty commands
	if w[1] == nil then
		return
	end
	
	local func = self.commands[w[1]]
		
	if func then
		func(w, ...)
		return true
	else
		return false,w
	end
end
