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

uisprites = {}

-- get all the files "blah.something" and store them at index "blah"
local path = "uisprites"

local ls = LF.enumerate(path)
for i,v in ipairs(ls) do
	local f = path .. "/" .. v
	if LF.isFile(f) then
		uisprites[string.gsub(v, "%..*$", "")] = LG.newImage(f)
	end
end
