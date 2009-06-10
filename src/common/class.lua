-- class.lua
-- Copyright (C) 2009 Noé Falzon

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

--[[
A simple class system in Lua for OOP programming
version 1.0 (2009-02-13)
by Noé Falzon

Creation of a class:
====================

MyClass = class()

This class is created with a default new() and init() method.
init() is called by new(), with the same arguments.
The default init() returns the instance.

Definition of methods:
======================

function MyClass:method()

end

The keyword self is available to refer to the message receiver.
The default init() method can be overloaded.
Do NOT overload new().

Members of the class are only defined by what the methods do. Typically,
self.member = something. A good idea is to list them all in init().

Instanciation:
==============

instance = MyClass.new(params)
instance = MyClass(params)

params are passed to the init() method.

Messaging:
==========

instance:method(params)

Access to object members:
=========================

It is not restricted, and can thus be done directly:

instance.member = expr
expr = instance.member

Note the special member class which points to the class of an object:

if object.class == Class then end

of for instance from inside a method: self.class

(class is actually a member of the Class table, but is accessible like methods to each instance)

Destroying instances:
=====================

instance = nil

When all references to an object are removed, garbage collection takes care of freeing memory.

Inheritance:
============

Child = class(Parent)

Child will inherit all methods of Parent, including init(). "Members" are inherited if the
methods that define them are not overloaded.
New methods are added the same way as before.

Method overloading:
===================

Defining a method with the same name as a parent method will replace it.
Accessing parent methods is possible through the member super. Typically in a method:

self.super:method()

Or outside the methods definition, instance.super:method() if you know what you're doing.

Trying to index super in a base class fails.

Recommended design:
===================

* init() should call the parent init(), since there might be important stuff done there,
  and always return self, since this is what is returned by the hidden method new().

function Child:init(a,b,c)
	self.super:init(a,b)
	self.c = c
	
	return self
end

* Methods that don't need to return anything may return self. It allows for chain calls:

object:dothis():dothat():andthis(param):andthat()

Notes:
======

Implementation uses metatables. The instances only have specific members, the methods (with class and super) being members of the Class table. Messages can thus be sent this way:

Class.method(object,params)

As class and super are transmitted to the instances, the following is possible:

Class.super.method(object,params)
if object.super == Class then end
if Class.super == OtherClass then end
if object.class == otherobject.super then end
etc.

Summary of reserved names:
==========================

:new()
.class
.super
and self as a parameter (used by Lua's : method calling syntax)

]]

class = function(base)
	local c = {}
	c.__index = c
	c.class = c
	
	-- default constructor (sets metatable and calls init)
	c.new = function(...)
		local obj = {}
		setmetatable(obj,c)
	
		-- automatically call init method with same arguments
		return obj:init(...)
	
		-- return obj
	end
	
	-- inheritance
	if base then
		setmetatable(c, {__index = base, __call = function(t, ...) return c.new(...) end })
		c.super = base
	else
		-- default init, needed by base class only. 
		-- the children always inherit one, or redefine one
		function c:init()
			return self
		end
		
		setmetatable(c, {__call = function(t, ...) return c.new(...) end })
	end
	
	return c
end

