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

require "common/class"

Console = class()

function Console:init()
	
	-- exec callback
	self.callback = callback or function(self,line) end
	
	self.widget = nil	-- set by gui_init()
	
	return self
end

function Console:execute(str)
	
	if str == "" then return end
	
	self:callback(str)
end

function Console:print(str)
	
	self.widget:AppendText(str .. '\n')
end
