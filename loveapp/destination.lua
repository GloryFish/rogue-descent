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

-- Return a table containing valid neighbors for the destination. May not be valid rooms. 
function Destination:getNeighbors()
  local neighbors = {}

  if self.level - 1 > 0 then
    if self.index - 1 > 0 then -- ul
      table.insert(neighbors, Destination(self.level - 1, self.index - 1))
    end
    if self.index <= self.level - 1 then -- ur
      table.insert(neighbors, Destination(self.level - 1, self.index))
    end
  end
  
  -- l
  if self.index - 1 > 0 then
    table.insert(neighbors, Destination(self.level, self.index - 1))
  end
  
  -- r
  if self.index + 1 <= self.level then
    table.insert(neighbors, Destination(self.level, self.index + 1))
  end

  -- ll
  table.insert(neighbors, Destination(self.level + 1, self.index))

  -- lr
  table.insert(neighbors, Destination(self.level + 1, self.index + 1))
  
  return neighbors
end

function Destination:__tostring()
	return "Destination ("..tonumber(self.level)..","..tonumber(self.index)..","..tonumber(self.id)..")"
end

function Destination.__eq(a, b)
	return a.level == b.level and a.index == b.index
end