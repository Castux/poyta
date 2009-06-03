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

love.filesystem.require("console.lua")

local LG = love.graphics

function load()
	
	love.graphics.setBackgroundColor(LG.newColor(255,255,255))
	cons = Console(80,24,"VeraMono.ttf",10)
	
	LG.setColor(LG.newColor(0,0,150))
end


function draw()

	LG.draw(love.timer.getFPS(),620,20)
	cons:draw()
end

function keypressed(key)
	cons:input(key)
end
