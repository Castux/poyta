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

require "Entity"

-- BasicEntity is just a "virtual" class from which derive, well, the basic entities.
-- It doesn't do much.

BasicEntity = class(Entity)

-- this can be used also " if v.isbasicentity then", of course
-- (calling nil is not advised)
function BasicEntity:isbasicentity()
	return true
end

-- this has to be overloaded...
function BasicEntity:compare(other)

	-- all BasicEntities are the same, so...
	return other.isbasicentity
end
