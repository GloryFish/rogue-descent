--
--  destination.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-03-01.
--  Copyright 2012 GloryFish.org. All rights reserved.
--


require 'middleclass'

Destination = class('Destination')

function Destination:initialize(level, index)
  assert(level > 0, 'level must be greater than 0')
  assert(index > 0, 'index must be greater than 0')
  assert(index <= level, string.format('index (%i) may not exceed level (%i)', tonumber(index), tonumber(level)))
  
  self.level = level
  self.index = index
  self.id = self:getId(level, index)
end

function Destination:getId(level, index)
  return ((self.level - 1) * self.level / 2) + self.index
end

function Destination:__tostring()
	return "Destination ("..tonumber(self.level)..","..tonumber(self.index)..","..tonumber(self.id)..")"
end

function Destination.__eq(a, b)
	return a.level == b.level and a.index == b.index
end