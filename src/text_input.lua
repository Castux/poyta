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



-- this very crappy function converts Löve's key numbers into
-- text. of course since we don't pay attention to locales and stuff, 
-- it's not only ugly, but very inefficient

-- WAITING FOR LÖVE 0.6 AND A PROPER TEXT INPUT!!

function text_input(key)
	
	local shift = love.keyboard.isDown(love.key_lshift) or love.keyboard.isDown(love.key_rshift)
	
	if key <= 126 and key >= 32 then
		

		if key <= 122 and key >= 97 and shift then
			-- caps
			key = key - (97-65)
		end
		
		return(string.char(key))
	
	elseif key >= love.key_kp0 and key <= love.key_kp9 then
		return(string.char(key - love.key_kp0 + love.key_0))
	
	elseif key == love.key_kp_period then
		if shift then
			return(":")
		else
			return(".")
		end
	end
	
end
