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


-- this is a probably temporary way to pick colors:
-- using the contextual menu
-- callback takes r,g,b as arguments

colorpicker = function(callback)

	Menu:init(love.mouse.getX(), love.mouse.getY())
	
	Menu:add("White", function()
		callback(255,255,255)
	end)
	
	Menu:add("Light grey", function()
		callback(200,200,200)
	end)
	
	Menu:add("Dark grey", function()
		callback(100,100,100)
	end)
	
	Menu:add("Red", function()
		callback(255,0,0)
	end)
	
	Menu:add("Yellow", function()
		callback(255,255,0)
	end)
	
	Menu:add("Green", function()
		callback(0,255,0)
	end)
	
	Menu:add("Cyan", function()
		callback(0,255,255)
	end)
	
	Menu:add("Blue", function()
		callback(0,0,255)
	end)
	
	Menu:add("Magenta", function()
		callback(255,0,255)
	end)
end
